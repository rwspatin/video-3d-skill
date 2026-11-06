# Blender headless on macOS / Apple Silicon

Lessons from seven look-dev rounds (`ezekiel-ophanim-v3`..`v7`) and the final 504-frame render
(`ezekiel-ophanim-v7`) of a real project. Paths below are relative to `~/git/personal/angels-sim/`
unless stated otherwise. Machine: Apple M4, 16 GB, Blender 5.2.3 LTS, Cycles Metal.

## Invocation

Binary path and CLI pattern used throughout (source: `ezekiel-ophanim-v7/tools/render_final.sh:10`,
`ezekiel-ophanim-v7/v7.py:5-10`):

```bash
B=/Applications/Blender.app/Contents/MacOS/Blender
$B -b --factory-startup -P script.py -- --shot hero --out out/stills/x.png --samples 192
```

`-b` (background), `--factory-startup` (no user prefs/add-ons bleeding in), `-P script.py --` then
your own argv after the `--`. Every render script in this project parses its own args after `--`
with `argparse` (source: `ezekiel-ophanim-v7/v7.py:49` `ap.add_argument("--samples", ...)`).

## Cycles Metal + OIDN setup (source: `ezekiel-ophanim-v7/encounter.py:1252-1289`)

```python
prefs = bpy.context.preferences.addons["cycles"].preferences
prefs.compute_device_type = "METAL"
prefs.refresh_devices()
for d in prefs.devices:
    d.use = d.type == "METAL"
cy = bpy.context.scene.cycles
cy.device = "GPU"
cy.use_denoising = True
cy.denoiser = "OPENIMAGEDENOISE"
cy.denoising_input_passes = "RGB_ALBEDO_NORMAL"
cy.denoising_prefilter = "ACCURATE"
cy.denoising_use_gpu = True  # wrap in try/except; not available on every build
```

Adaptive sampling (same file, lines 1267-1269): `use_adaptive_sampling = True`,
`adaptive_threshold = <per-shot threshold>`, `adaptive_min_samples = min(32, samples)`.

Bounce/clamp settings actually shipped, two layers:
- Base (`encounter.py:1278-1288`, round-3 defaults): `max_bounces=8, diffuse_bounces=3,
  glossy_bounces=3, transmission_bounces=8, volume_bounces=1, transparent_max_bounces=12,
  sample_clamp_indirect=8.0, blur_glossy=0.7, caustics_reflective=False, caustics_refractive=False,
  use_light_tree=True`.
- Overridden per-round in `v7.py:814-826` for the crystal/haze-heavy scene: `transmission_bounces=10,
  glossy_bounces=4, max_bounces=12, transparent_max_bounces=16, sample_clamp_indirect` env `CLAMP`
  (final render used `3`), `sample_clamp_direct` env `CLAMP_DIRECT` (final used `12`, v6's clip used
  `24` to kill green fireflies at glints — source: `ezekiel-ophanim-v6/METRICS.md:59` and `v7.py:825`),
  `blur_glossy=1.0`, `volume_step_rate=4.0`.

Final render settings that shipped (source: `ezekiel-ophanim-v7/METRICS.md:26-29`): 75 % resolution
(810×1012) → Lanczos upscale to 1080×1350 in ffmpeg, **16 spp max**, adaptive threshold **0.12**,
OIDN, clamp indirect 3 / direct 12, motion blur 0.5 (object motion only, see below), 8-frame chunks.

## Resilience rules (all required for an unattended multi-hour render)

1. **One Blender process at a time.** Checked by hand with `pgrep -fl Blender` before every batch in
   v3-v5 (source: `ezekiel-ophanim-v3/METRICS.md:4-5`); from v6 the render scripts check it themselves
   and refuse to start (source: `ezekiel-ophanim-v6/METRICS.md:4` "the render scripts now refuse to
   start if another Blender is running"). The final scripts do: `pgrep -f "Blender -b" >/dev/null &&
   echo "another Blender is running; abort"` (source: `tools/render_final.sh:8`,
   `tools/render_final_v2.sh:7`).
2. **8-frame chunks, each a fresh process.** Prevents the per-process memory growth described below;
   explicit in the script header (source: `tools/render_final.sh:2-3`).
3. **Resumable.** Before rendering frame range `a-b`, check whether the chunk's *last* frame PNG
   already exists; skip the chunk if so (source: `tools/render_final.sh:23`,
   `if [ ! -f out/final/$shot/raw/f_$(printf %04d $b).png ]`).
4. **Detached with its own log.** `nohup tools/render_final.sh &`, redirected to
   `out/final/render.log` (source: `ezekiel-ophanim-v7/METRICS.md:3-4`; the script does
   `exec >> out/final/render.log 2>&1`).
5. **Watchdog.** `render_final_v2.sh` kills and restarts a chunk if no new frame file appears for
   **480 s (8 min)**, up to 3 tries (source: `tools/render_final_v2.sh:4`, loop at lines 25-40). The
   plain `render_final.sh` (round B1-B5) has no watchdog — a hung chunk there needed a human restart
   (source: `ezekiel-ophanim-v7/METRICS.md:43-45`, "Chunk 73-80 hung ... the job was restarted").
6. **Check machine load before a long render.** Not verified as an explicit pre-flight command in the
   project docs (no doc names `uptime` or `sysctl vm.swapusage` literally) — but every multi-hour
   render that *wasn't* checked first got hit by exactly this: a video call + browsers pushed swap to
   12-18 GB and roughly doubled frame time (source: `ezekiel-ophanim-v5/METRICS.md:48-49,100-101`); two
   Chrome processes at ~100 % CPU plus the Metal compiler service at 261 % caused the 65-130 s/frame
   spike and the hung chunk in the final B2 render (source: `ezekiel-ophanim-v7/METRICS.md:42-43`). Run
   `uptime` and `sysctl vm.swapusage`, and close Chrome/video-call apps, before starting anything that
   will run unattended for hours — this is a recommended rule derived from the failures, not a command
   quoted from the sources.
7. **Persistent data OFF, no deformation motion blur.** Persistent data + per-frame attribute edits on
   4×3 instancers grew one process to 20 GB by frame 4 (swap thrash, 67→240 s/frame); deformation blur
   on 901k-vertex rings plus 12 instancers pushed it to 13-20 GB separately (source:
   `ezekiel-ophanim-v5/METRICS.md:48-50`, `v7.py:827-837`). Fix, applied from v6 onward to every shot:
   `sc.render.use_persistent_data = False`, every object's `.cycles.use_deform_motion = False`,
   `motion_blur_position = "CENTER"` (object motion blur is enough — the rings/eyes move rigidly with
   their spin empties). Re-trying persistent data ON in v7 Phase 1 reproduced the climb (32→73 s/frame
   within one chunk, no gain) — kept off (source: `ezekiel-ophanim-v7/METRICS.md:24`).

## Cost levers measured (in order of leverage)

| Lever | Measured effect | Source |
|---|---|---|
| Per-frame scene export, not pixel count, dominates | at 25 % / 6 spp a frame still took 35-50 s | `ezekiel-ophanim-v7/NOTES.md:14` |
| Coarsen distant terrain (`TERRAIN_RES=0.55`, `LEDGE_RES=0.7`) | 55 s → 26 s per B1 frame at 75 %, visually identical | `ezekiel-ophanim-v7/METRICS.md:21-23`, `NOTES.md:14-15` |
| Render at 75 % + Lanczos upscale to delivery res | part of the final 16 spp / 29.3 s mean | `ezekiel-ophanim-v7/METRICS.md:26-28` |
| Drop the storm cloud from a volume to an emissive "plate" | still cost 72.8→82.2 s (v5→v6) vs 319 s (v4, with volumetric cloud) | `ezekiel-ophanim-v6/METRICS.md:24-30` |
| External GPU/CPU load from other apps | same scene: 37 s → 121 s per frame | `ezekiel-ophanim-v7/METRICS.md:19` |
| Lower sample count + adaptive threshold | stills 192 spp/0.01 (v3) → 128 spp/0.015 (v4-v6) → final 16 spp/0.12 (clip/chunked render) | `v3/v4/v5/v6 METRICS.md` headers |

**Estimate method and what it got wrong:** render 3 test frames, multiply by frame count (source:
`ezekiel-ophanim-v7/METRICS.md:12`, "Phase 1 ... 3 test stills, cost bisect"). The first estimate this
way came out at **222 s/frame** (75 %, 12 spp) and was wrong for two compounding reasons, not one:
(1) another process was holding the GPU at 76 % with no Blender running at the time of the test — the
same scene dropped to 37 s/frame once that process ended; (2) the per-frame scene export cost (not
pixel count) meant even a cheap 25 % test still ran 35-50 s/frame until the terrain was coarsened
(source: `ezekiel-ophanim-v7/METRICS.md:18-23`). A 3-frame test taken while something else holds the
GPU, or before the cheap scene-cost fixes land, will overestimate badly — re-test after clearing both.

## Recipes that worked

- **Cloud as a backdrop plate, not a volume.** A backlit volumetric storm cloud rendered as a flat
  brown blob at every density tried (source: `ezekiel-ophanim-v5/METRICS.md` "Rejected" #1; a separate
  procedural volume *cloud sea* ground fog cost 566 s at 50 %/32 spp vs 18-35 s for a mesh, source
  `ezekiel-ophanim-v3/METRICS.md:41`). The v6 fix: 4 camera-facing emissive cards with domain-warped
  noise alpha, a gold rim (brighter on the sun side) and amber fire in the folds — emission +
  transparency, so it costs almost nothing, and it must **not** cast shadow (try 1's cloud shadow
  blacked out the ridge) (source: `ezekiel-ophanim-v6/NOTES.md:48-52`). Cost after the fix: 82-98 s per
  still vs 72-153 s the round before (source: `ezekiel-ophanim-v6/METRICS.md:20-30`).
- **God rays via an invisible, shadow-only screen**, not a visible volume. A perforated plane (noise
  holes + one hole per key subject's sun line) at 1.6 km, visible to nothing (`visible_camera = False`
  etc.) except shadow rays into one homogeneous haze volume starting beyond the subjects. Gotcha:
  `visible_volume_scatter` must be **True** even though the screen is invisible to camera — setting it
  `False` also removed it from the volume's own shadow rays, so no shafts appeared at all (source:
  `ezekiel-ophanim-v5/NOTES.md:9-13`; code in `ezekiel-ophanim-v7/v7.py:444-487`). Earlier attempts
  that failed: heterogeneous noise-streaked shafts + a radial-falloff halo cost 660 s for a 25 % test
  frame and washed the frame milky; nested homogeneous shells showed hard disc edges (source:
  `ezekiel-ophanim-v4/METRICS.md` "Rejected" #1-2).
- **Instanced eyes, ~800 per wheel.** Dart-throwing on the ring's own surface metric, largest circles
  placed first (v4-v7: 30 large + 100 medium + the rest small per ring, `n_try=3200`, spacing factor
  1.34 → **836 eyes/wheel, 3,344 for four**; source: `ezekiel-ophanim-v7/ophan4.py:27`,
  `ezekiel-ophanim-v7/FIDELITY.md:17`). v3's version (764/wheel) used 34 large + 110 medium, spacing
  1.36 (source: `ezekiel-ophanim-v3/METRICS.md:22,65`). At hero framing distance the eyes are still
  only 15-50 px and read as crescents, not individual eyes — a known, disclosed limit, not a bug
  (source: `ezekiel-ophanim-v3/METRICS.md:118`).
- **Cloth sim for a mantle**, baked once to a cache and reused: `python3 encounter.py -- --sim` bakes
  the cloth to `out/sim/*.npz`; later shots load the cache instead of re-simulating (source:
  `ezekiel-ophanim-v7/encounter.py:7` docstring). A larger re-pose ("lying", 1.8×2.55 m mantle) cost
  ~75 s per sim (source: `ezekiel-ophanim-v7/METRICS.md:89`).

## Recipes that failed, and why

- **Prostrate human figure reading as "cloth" instead of a man.** The body under the mantle is a proxy
  built from capsules/ellipsoids (`BODY_PARTS`, `HULL` in `encounter.py`), not a fully posed, readable
  figure; at distance this reads as "a small grey lump — not clearly a man on his face" (source:
  `ezekiel-ophanim-v7/METRICS.md:80-81`). The v2 reshoot (closer camera, new "lying" pose, bigger
  mantle) still read as "a person under a spread sheet (outstretched arms not readable through it)"
  (source: `ezekiel-ophanim-v7/METRICS.md:98-99`). **What would fix it:** a fully posed body with
  readable limb silhouettes under the cloth, not a minimal capsule hull — the sim was never the
  problem, the thing being simulated over was too generic to read through drape (source generalizes
  `ezekiel-ophanim-v3/METRICS.md:128-129`, "the man is a cloth sim over a proxy ... fine at these
  distances, from behind" — i.e. it only ever worked because earlier shots never looked at him
  head-on/close).
- **Thin-film rainbow (1:28) on the crystal.** At 420 nm it tinted the whole stone gold/olive instead
  of a grazing-edge rainbow; dropped (source: `ezekiel-ophanim-v4/METRICS.md` "Rejected" #4).
- **Prismatic halo at the ring crossings.** Tried in v4-v7 look-dev, never shipped: "not cheap enough
  to do convincingly" every round (source: `ezekiel-ophanim-v6/NOTES.md:22`, repeated in v5/v7 notes).

## Asset licensing (Poly Haven, CC0)

All external assets are Poly Haven CC0 1.0, fetched with `python3 -I tools/fetch_assets.py` against
the public `api.polyhaven.com`, each file **md5-checked** against the API's own manifest before being
written to disk (source: `ezekiel-ophanim-v7/tools/fetch_assets.py:36-47`; see the `fetch()` function —
on mismatch it raises, it never writes a bad file). Only images (HDR/JPG) and glTF meshes were
downloaded — no scripts, no `.blend` files, no add-ons; glTF files were inspected as plain JSON before
import (source: `ezekiel-encounter/ASSETS.md:1-6`). CC0 needs no attribution; it's listed anyway in
the project's `ASSETS.md` table (HDRIs, rock/boulder models, ground textures, linen texture — 10
assets total).

## Verification habits

- **Read first/middle/last frame of every shot**, every round (source: `ezekiel-ophanim-v7/METRICS.md`
  "Verification" section).
- **100 % crops** at the ring crossings / eye clusters to check for popping, crawling or fireflies
  (source: e.g. `ezekiel-ophanim-v6/METRICS.md:44-45`, `out/tests/clip_crops_f24-27_100.png`).
- **Consecutive-frame mean absolute difference** as a numeric flicker check — a smooth monotonic or
  single-hump curve with no spike at chunk boundaries is the pass criterion (source:
  `ezekiel-ophanim-v5/METRICS.md:53`, `ezekiel-ophanim-v6/METRICS.md:42-45`).
- Explicitly **not done** on the final 504-frame render: frame-by-frame review of all 504 frames, a
  full-resolution flicker check on every shot (source: `ezekiel-ophanim-v7/METRICS.md:65`). Say so
  rather than claim full coverage.

## What to do differently next time

1. Run a GPU/swap/CPU check (`uptime`, `sysctl vm.swapusage`, `ps` for Chrome/video-call apps) and
   close anything heavy *before* starting a multi-hour render, not after a frame-time spike reveals it.
2. Add the `render_final_v2.sh` watchdog to the *first* long render, not the redo — it was missing for
   the very run that hung for ~50 min (source: `ezekiel-ophanim-v7/METRICS.md:13,43-45`).
3. Build the prostrate/fallen figure as a fully posed body from the start for any shot that frames him
   closer than "small and distant" — don't discover the proxy-under-cloth limit at delivery time.
4. Re-run the 3-test-frame cost estimate only after confirming the GPU is idle and the cheap scene-cost
   fixes (terrain coarsening, no persistent data) are already in — otherwise the estimate is not
   actionable (see "Estimate method" above).
5. Decide the cloud strategy (plate vs. volume) before the first full-still pass; volumetric clouds
   lost outright in every round they were tried (v3 ground fog, v4/v5 storm cloud).
