# Three.js teardown: interactive explainer + film from one model

Lessons from building `ezekiel-part-a-v2` (Track A of "The Wheels of Ezekiel") on top of
`~/.claude/skills/teardown/SKILL.md`. Paths below are relative to `~/git/personal/angels-sim/`
unless stated otherwise.

## When to use this over a hand-animated video

Use the teardown skill when you need an **interactive explainer and a film from the same model**,
not two separate builds. The project's own framing: "One Three.js model drives the film, the live
page, every number on screen and the score" (source: `ezekiel-part-a-v2/NOTES.md:5`). That one-model
rule is the teardown skill's rule 2, "Real numbers, one source": every gauge, chart and label reads
from the same function that poses the parts, so nothing on screen can disagree with the motion
(source: `~/.claude/skills/teardown/SKILL.md`, "Rules that decide whether it works", #2). Concretely
in this project, `shared/film.js`'s `readouts()` function is the single source both the live HUD and
the exported film's overlay read from (source: `ezekiel-part-a-v2/NOTES.md:73`, "Live panels (all read
from the posed scene, `shared/film.js readouts()`)").

Reach for it when the deliverable needs **both** an offline interactive page (for a site, a social
post people can touch) **and** a rendered video (for a feed) describing the same mechanism, and the
numbers shown in both must be guaranteed consistent — not when you only need one or the other.

## The capture pipeline

Playwright drives a cached, pinned Chromium rather than whatever Playwright would download on its
own: the build command sets `CHROMIUM` to the cached Chrome for Testing build itself before running
the capture script (source: `ezekiel-part-a-v2/NOTES.md:95-97`, rebuild command ends with
`./tools/film.sh` — "it sets CHROMIUM to the cached Chrome for Testing 1248 itself"). The teardown
skill documents this as a general override point: "Set `FFMPEG`, `PYTHON` or `CHROMIUM` to point at
other binaries" (source: `~/.claude/skills/teardown/SKILL.md`, "First run" section). Pin the exact
Chromium build path once per machine (`~/Library/Caches/ms-playwright/chromium-1248/...` in this
project — see `final-film/build.sh:15`) so every later capture is reproducible.

**One capture process at a time.** The chapter-by-chapter capture tool (`tools/film.sh`) runs "one
Playwright at a time" (source: `ezekiel-part-a-v2/NOTES.md:91-93`, Files section). This matters
because a Blender render was running on the same GPU for most of this build (source:
`ezekiel-part-a-v2/METRICS.md:4`) — the project logged whether Blender was running at the start of
each chapter capture specifically because it inflates the numbers (same source, header note). Do not
run two capture/render processes against the GPU at once if you need trustworthy per-frame timings.

**Frame by frame to ffmpeg**, not a continuous screen recording: capture each chapter's frames at CSS
1080×1350, device-pixel-ratio 1.6 (1728×2160 supersampled), encode each chapter to an intermediate
clip (x264 crf 14), then join and scale to delivery resolution (Lanczos, crf 17) (source:
`ezekiel-part-a-v2/METRICS.md:31-33`). This is the same per-chapter-clip-then-concat approach used
downstream in `final-film/build.sh` for the Blender shots (see `assembly.md`).

## The label/band collision check ("maskcheck")

A caption band (reserved top/bottom regions where text lives) must never have wheel or figure pixels
inside it. Two separate tools enforce this in this project:

- `tools/maskcheck.mjs` — checks caption bands **and leader labels** (not just the two bands) against
  wheel pixels, every 0.25 s across 64 frames; result in the delivered build was **0 crossed** (source:
  `ezekiel-part-a-v2/NOTES.md:91`, `METRICS.md:22` "Mask checks ... 1 → 0 crossed").
- A render-a-mask-and-count-pixels variant of the same idea, `tools/band_check.py`, exists in the
  Blender track (`ezekiel-ophanim-v7/tools/band_check.py`): render subject mattes (wheel = red, man =
  green, rest black) via `encounter.py --mask`, then count subject pixels inside the reserved bands and
  print the subject's vertical pixel extent; exit code 1 if anything crosses. Build this kind of check
  as a **pixel-counting pass over a semantic mask**, not a bounding-box guess — bounding boxes miss a
  wheel's actual silhouette curving into a band while its bbox still clears it.

Run the check after every layout or camera change, not just once before delivery — this project's
B-shot captions in the final assembly were re-verified against actual re-rendered footage, not
assumed from camera data, specifically because framing changed late (B4/B5 reshoot; see
`assembly.md` and `final-film/SHOTLIST.md`'s "Caption band placement per B-shot" section).

## The procedural score

The film's audio is synthesized, not a stock track: `shared/score.py`, run through
`~/.claude/skills/teardown/run_sfx.py`, reads the same timeline the visuals are keyed to (source:
`ezekiel-part-a-v2/NOTES.md:96`, rebuild command). Mastering target: **−14.0 LUFS integrated**, LRA
2.4 LU, true peak −7.5 dBFS on the standalone score WAV (source: `ezekiel-part-a-v2/METRICS.md:50-52`).
This score was reused unmodified by the downstream film assembly (`final-film/build.sh`) rather than
re-rendered — see `metrics-and-honesty.md` and `assembly.md` for how reuse across tracks was tracked.

## Honest limits (disclosed in METRICS.md, not discovered by a viewer)

- **Eyes are small at film distance.** 836 eyes on a 2.4 m wheel render as 6-40 px wide in the 1080
  frame even in the closest chapter (A2); at 100 % crop they read as almond eyes with gold lids and
  warm irises, but there is no corneal refraction or wet highlight the way the Blender macro shot has
  it — in the four-wheel chapter (A4, 3,344 eyes) they are gold flecks (source:
  `ezekiel-part-a-v2/METRICS.md:80-82`).
- **The crystal is a WebGL approximation**: `MeshPhysical` transmission + attenuation + emissive
  amber, not real subsurface scattering. Near the ring crossings the stone goes pale cream-gold, same
  as the Blender stills but flatter; gold collars bloom into small star-like flares, busiest in the
  four-wheel chapter (source: `ezekiel-part-a-v2/METRICS.md:83-85`).
- Procedural sky: the storm bank reads as a dark ragged band with gold rims but has no volume, thin
  rims, and gaps that can look washed-out pale cream; clouds drift very slowly (source: same METRICS
  file, "What looks wrong" section).
- Live-page frame rate (24-35 fps) was measured **only on the M4, with Blender rendering concurrently**
  — unknown on an integrated-GPU laptop or a phone (source: `ezekiel-part-a-v2/METRICS.md:56-58,96`).

## Measured numbers (every one sourced)

| Metric | Value | Source |
|---|---|---|
| Total build wall-clock | 36 min | `ezekiel-part-a-v2/METRICS.md:14` |
| Per-chapter capture cost | A1 0.194 s/frame, A2 0.208, A3 0.208, A4 0.247; mean 0.214 | `ezekiel-part-a-v2/METRICS.md:36-40` |
| Whole pipeline (capture + join/scale + mux) | 1 min 33 s (no Blender running); 2 min 09 s (Blender running throughout) | `ezekiel-part-a-v2/METRICS.md:42` |
| Score synthesis | 8.2 s | `ezekiel-part-a-v2/METRICS.md:43` |
| Final film | 10.8 MB, H.264 1080×1350 24 fps, 384 frames, 16.000 s, AAC 256 kb/s, −14.0 LUFS | `ezekiel-part-a-v2/METRICS.md:50` |
| Live page | 851 KB (871,895 B), one offline file, interactive | `ezekiel-part-a-v2/METRICS.md:53` |
| Eye count | 836/wheel, 3,344 for four | `ezekiel-part-a-v2/NOTES.md:41` |
| Live-page fps | tour ~26-35, in control ~24-26, quality governor drops a tier below 30 | `ezekiel-part-a-v2/METRICS.md:56` |

## Verification

Final verification pass read 9 full frames from the **encoded** MP4 (not the source canvas), 4 crop
sheets at 100 %, 3 consecutive frames (flicker check), and the teardown skill's own 12-frame beat
sheet (source: `ezekiel-part-a-v2/METRICS.md:27`). Every-frame numeric check
(`tools/checkframes.mjs`) verified the posed model's own claims across all 384 frames: turned angle
max 0°, cross-ring angle 90° ± 1e-14, stride distance = π·R exactly (source: same file, line 23). Not
verified: live-page frame rate on any GPU other than the build machine's own M4.
