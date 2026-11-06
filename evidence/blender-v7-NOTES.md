# Ophanim v7 — the FINAL Part B film (B1-B5, 21 s) + last look fixes

v7 = v6 (`v7.py` = v6.py copied and extended; `ophan4.py` and the `encounter.py` copy extended). v3-v6 untouched.

Look fixes (Phase 1, tests `out/tests/p01-p02`):
- **Fire inside the crystal**: `FIRE_BODY` (0.9) — molten amber veins through the whole band (ring-local noise, so they
  travel with the spin), strongest looking straight into the stone, kept off the eye mounds; on top of the crossing fire.
- **Sun just inside the left edge** (`VIEW_AZ` 336) with its own dark cloud card over it (card 5), so it hides behind
  the gold-rimmed bank; shafts come from the shadow screen as before.
- **Background wheels** moved to 380-650 m, in front of the haze (which now starts at 480 m): they keep the amber/green
  body instead of pale "ghost glass".
- **Man smaller in 02**: camera 4.6 m behind him (v6: 2.6 m).
- **Fireflies**: clamp indirect 3, direct 12.
- **Cost**: ridge / far terrain meshes coarsened (`TERRAIN_RES` 0.55, `LEDGE_RES` 0.7, visually identical at these
  framings) — the per-frame scene export, not pixels, dominated the frame time: 55 s -> 26 s per frame at 75 %.

Part B (`shot_final`, `FINAL_SHOT=B1..B5`, `tools/render_final.sh`):
| Shot | Frames | Content |
|---|---|---|
| B1 | 120 (5 s) | hero framing; the four wheels descend 60 m out of the cloud level and settle (staggered); slow dolly-in 2.5 m |
| B2 | 96 (4 s) | over the shoulder; slow dolly-in 0.5 m; rings spinning 25-37 deg/s |
| B3 | 96 (4 s) | macro on the eyes, sky behind; the eyes turn from the viewer to the man (gaze target camera -> man, weight 0.35 -> 0.85, t 0.8-2.6 s); rings slowed to 6 % (1.5-2 deg/s) so the eyes stay in frame |
| B4 | 96 (4 s) | low angle; the hero wheel rolls exactly half a turn (pi R = 126 m) toward the ridge at ~35 deg to the view line, ring A turning ONLY by rolling (spin 0), ring B spinning; the body never yaws (1:17) |
| B5 | 96 (4 s) | the man already prostrate (2:1) — no fall animated (too costly to make convincing: needs a rig + cloth that follows); wheels still (no spin, no bob), eyes on him; slow dolly-in 1.4 m |

Cameras are static or slow dollies only: the cloud is a backdrop plate (no parallax). Rendered at 75 % with 16 spp and
Lanczos-upscaled to 1080 x 1350; per-shot PNG sequences (`out/final/Bx/png/`) and silent mp4s (`out/final/Bx.mp4`).

## final_v2 redo (B5 then B4) -> `out/final_v2/`

- **B5 v2**: new pose `lying` in the `encounter.py` copy: full length on his face, forehead down, arms stretched
  forward toward the vision, feet toward the camera; robe + a larger mantle (1.8 x 2.55 m) re-simulated over it
  (`out/sim/*_lying.npz`, ~75 s each). Camera close, low, behind and a little above him (`B5_V2=1`, dolly
  (0.6,-5.0,1.6) -> (0.55,-4.2,1.5), 24 mm, aimed at (-8,53,13)): he fills ~30 % of the frame width at the bottom; the
  wheels stand still and tower behind with the cloud. Bug found on the way: B5 forced `POSE=prostrate` in code.
- **B4 v2**: original camera, panned right (`B4_AIM` 2,0,6) with a 19 mm lens so the man is fully in frame; valley
  haze cut to 0.0003 in this shot so the wheel no longer starts washed out on the sun side. Half-turn roll unchanged.
- `tools/render_final_v2.sh`: same settings and safety as `render_final.sh` plus a watchdog (a chunk with no new frame
  for 8 min is killed and restarted, max 3 tries).

---

# Ophanim v6 notes


v6 = v5 (`v6.py` = v5.py copied and changed; `encounter.py` copy gets a `RELIEF` knob). v3/v4/v5 untouched.

- **The great cloud (1:4) is back as a cloud plate**: 4 camera-facing emissive cards in the sun's quadrant at 1.5-2.4 km
  (`build_cloud_cards`): domain-warped noise alpha, blue-grey storm body, a **gold rim** where the cloud thins
  (stronger on the sun side) and **amber fire in the inner folds** ("a fire infolding it"). Emission + transparency,
  so they cost almost nothing; they do NOT cast shadow (try 1: their shadow blacked out the ridge). The god rays still
  come from the invisible perforated shadow screen (v5) into the homogeneous haze. Took 3 tries (c01-c03), no fallback.
- **Sun just outside the left edge**: camera turned to az 344 (`VIEW_AZ`), haze anisotropy 0.75 -> 0.62: the glare is
  gone from frame, the rays stay.
- **Bigger wheels / man in the wide shots**: hero wheel at 150 m (v5: 215 m), camera 6.5 m behind the man (v5: 10 m);
  the four-wheel formation at 215 / 330 m (v5: 300 / 440 m), 20 mm lens.
- **Brighter inner fire**: FIRE 0.4, core lamps 6e5 W (macro keeps 0.14).
- **Foreground blotches**: they were the terrain's own 2.5 m micro-relief self-shadowing under the low sun (isolated:
  they vanish with the sun off, persist with the screen off). Fixed by `RELIEF=0.35` (shelf relief x0.35) and a softer
  sun (4 deg disc).
- **Fireflies**: direct-light clamp 24 (v5 had none) + glossy filter 1.0.
- **Memory-safe defaults for every shot**: persistent data off, deformation motion blur off, motion blur position
  centre (v5 only had them for the clip). `tools/render_v6.sh` and `tools/render_v6_clip.sh` write their own logs and
  refuse to start if another Blender is running (safe with `&`).
- Prismatic halo at the crossings: not built (not cheap enough to do convincingly).

---

# Ophanim v5 notes (still valid)


v5 = v4 (`ophan4.py`, wheel/eyes/spin/blink; `v5.py` = v4.py copied and extended) with these changes
(v3 and v4 folders untouched):

- **Camera looks toward the sun.** Sun lamp WNW (az 298, el 12: a summer-evening sun at the Chobar's latitude can
  set as far north as ~298); the vision stays to the north, off-axis right of frame. The wheels and the man are
  backlit; the man gets a rim of sun on the left edge of his mantle.
- **God rays are real light, not paint**: a shadow-only "sun screen" (an invisible perforated plane facing the sun at
  1.6 km: noise holes + one hole on the sun line of the hero wheel and one on the camera/man) casts long shafts into
  one homogeneous haze volume that starts just beyond the wheels (250 m) and runs out past the screen. The shafts
  radiate from the sun toward the lens. Gotcha found: with `visible_volume_scatter = False` the screen did not shadow
  the volume at all (no rays); it must be True (it still is invisible to camera, diffuse, glossy, transmission).
- **The storm cloud**: the v4 volumetric deck rendered as a flat brown blob when backlit (tests t01-t05, also at low
  density). Dropped from the stills; the visible clouds are the HDRI's own evening cumulus, lit gold from behind, and
  the "storm" is carried by the broken light (screen) instead. `VOL_CLOUD=1` brings the volume back.
- **Halo**: the wheels' amber core lamps now light the haze (v4 excluded them).
- **Ring spin at video rates**: 25-37 deg/s per ring (wheel 0: 25 / 37; others +-26..34), out of phase.
- **Lighter lids**: upper-lid openings 0.40 / 0.46 / 0.52 (v4: 0.32 / 0.39 / 0.46).
- **Fire inside a bit stronger and wider at the crossings** (FIRE 0.22, crossing band 0.80-1.0); macro uses 0.14.
- Clip: `tools/render_v5_clip.sh` (6 fresh processes of 8 frames; persistent data and deformation blur off -- with
  them on, Blender grew to 13-20 GB). Framing check without rendering: `CHECK_ONLY=1 ... --shot four`.
- Prismatic halo at the crossings: **not built** (no cheap version found in the time; real dispersion dropped as asked).

---

# (v4 notes, still valid for the wheel)


Answers the user's three notes on v3: (1) the rings must turn on their own axes, not just roll; (2) not flat green —
"more divine"; (3) much more light. Built in Blender 5.2.3 / Cycles Metal from code. v3 (`ophan3.py`) and the round-3
scene (`encounter.py`, terrain, man, cloth caches) are copied here and imported unmodified; `ophan4.py` and `v4.py` are
new. Nothing in other folders was touched; nothing posted, committed, uploaded or installed; no paid API.

- `ophan4.py` — the v4 wheel: hybrid band, per-wheel object hierarchy, spin/gaze/blink posing, crystal material.
- `v4.py` — the storm break (cloud with gaps, sun shafts, halo), shots, the clip.
- `FIDELITY.md`, `METRICS.md` — verse map (new elements flagged) and the numbers.

## Structure (hybrid: v2 legibility + v3 eyes)

- Band at the explainer size (R = 1.2 m, x33.3 -> R = 40 m real): **H 0.30 m tall, W 0.115 m thin** (v3: 0.29 x 0.19,
  a fat torus-like tube), fillet 0.022 m. Thin, flat, tall rims read as *wheels*, and the pair as "a wheel in the
  midst of a wheel" (1:16).
- Eyes on every face of both rings (dart throwing, largest first, spacing 1.34). **No eye-free tread any more**: the
  rings spin, so every part of the band passes every place; the bearing collars at the crossings are the only bare
  zones. Count in METRICS.md.

## Kinematics (the motion is an interpretive choice; FIDELITY.md)

Per wheel, an object hierarchy:

    Body (heading fixed: yaw never changes -- 1:17 "they turned not when they went")
     |- collars at the two crossings, the inner amber lamp (follows the body)
     |- SpinA -> ring A mesh + its eyes / lid beads / blink shells     (ring A lies in the body XZ plane, axis = body Y)
     '- SpinB -> ring B mesh + its eyes / lid beads / blink shells     (ring B lies in the body YZ plane, axis = body X)

- **Spin**: each ring rotates continuously about **its own axis** (A about body Y, B about body X) at its own slow
  rate: wheel 0 10 / 15 deg/s, wheel 1 -12 / 9, wheel 2 14 / -11, wheel 3 -9 / -13, with different start phases
  (the four are out of phase). The eyes sweep round each rim like a slow carousel. Because each ring turns only about
  its own axis, the two rings never collide: each slides through the other's collar (a gimbal/gyroscope with a
  fixed frame, not a free tumble).
- **Stride** (1:17 "they went by their four parts"): the body translates along ring A's plane (body X) by distance s;
  ring A gets the rolling term s / R on top of its spin (angle_A = spin_A * t + s / R); ring B, whose plane is
  perpendicular to the motion, only keeps spinning. A stride along body Y would add s / R to ring B instead. The body
  itself never yaws, so the wheel goes in any of the four directions without turning. (Strictly, a ring rolling on
  ground could not also spin freely; these wheels hover with the creatures, so spin is "the spirit of life in the
  wheels" (1:20) and the roll term keeps the rim speed consistent with travel when it moves.)
- **Bob/drift**: body position + (0.6, 0.5, 1.4) m sines with 7 / 9 / 5.5 s periods, phase per wheel.
- **Inner light hum**: the amber lamp and the crystal's fire emission x (1 + 0.10 sin(2 pi t / 3.3) + 0.05 sin(2 pi t /
  1.15)), plus a slowly evolving 4-D noise flicker in the fire field.
- **Eyes**: each eye's gaze turns part-way (weight 0.4, max 25 deg) toward the man's head, recomputed every frame in
  the spinning ring's frame (so the eyes track him as they sweep round), plus a slow per-eye wander (2.5-3.5 deg,
  3-6 s periods). **Blinks**: every eye blinks every 3.2-7.5 s (own period/phase), 0.32 s close-open, as four instanced
  lid-closure stages (a stone lid shell drawn over the opening).

## Material: "a jewel that burns"

- Translucent crystalline sea-beryl: hue field from deep sea-green through aquamarine to near-clear crystal (noise +
  wave "currents"), transmission + random-walk subsurface, glassy coat, a 420 nm thin film (faint rainbow at grazing
  edges, 1:28), polished.
- **Fire within** (1:4, 1:13, 1:27): emission in amber, placed in the wheel-body frame (it does not spin away),
  strongest at the two crossings and on the inner band, stronger when looking into the stone; an amber point lamp at
  each wheel's centre lights the inner faces and the surrounding haze.
- Gold-bronze: bearing collars at the crossings, gilded lid margins, bronze lid beads. Eyes keep v3's warm natural
  irises (amber/hazel/brown, some grey-green).

## Light: the heavens opened (1:1)

- Round 3's storm HDRI sky and great cloud (1:4), but with **gaps** placed on the sun line: one broad gap whose shaft
  falls on the key wheel, one narrow gap whose light pool falls on the man (rim light on the mantle).
- Sun moved up to el 38 (az 210, SSW) so a shaft can fall from the cloud gap; warm key, cool sky fill.
- Shafts and halo are **homogeneous** volumes (nested shells for a soft edge). The first, heterogeneous version
  (noise-streaked shafts, radial-falloff halo) cost 660 s for a 25 % test frame.
- Compositor bloom on the brightest amber.

Run e.g. `$B -b --factory-startup -P v4.py -- --shot four --pct 50 --samples 32 --out out/tests/x.png`.
Env knobs: `SUN`, `SUN_EL`, `SUN_AZ`, `SKY_K`, `CORE_W`, `FIRE`, `TRANS`, `SSS4`, `FILM`, `SHAFT_D`, `HALO_D`,
`EXPOSURE`, `BLOOM`, `GAZE_W`, `CLIP_N`, `STRIDE`, `MC_*`, `CROP`.
