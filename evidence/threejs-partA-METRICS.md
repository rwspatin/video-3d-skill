# METRICS: Part A v2 (teardown / Three.js) on the v6 wheel

Measured on this machine (Apple M4, 16 GB, headless Chrome for Testing 1248, ANGLE Metal). **A Blender/Cycles render
(another track, `ezekiel-ophanim-v7`) was running on the same GPU for most of this build**, so timings may be
inflated; `tools/film.sh` logs whether Blender was running at the start of each chapter.

## Wall clock (`date`)

| | |
|---|---|
| Start | Wed Nov 4 14:58:50 -03 2026 |
| Final film written | Wed Nov 4 15:31:44 -03 2026 |
| End (docs written) | Wed Nov 4 15:34:52 -03 2026 |
| Elapsed | 36 min |

## Iterations

| What | Count |
|---|---|
| Review sheets read (`out/iter1-5.png`, 3-12 full frames each) | 5 |
| Debug probes / 100 % crops during the build (`tools/probe.mjs`: sky alone, wide-fov sky layout, eye crops ×4, A1 panels) | 8 |
| Mask checks (every 0.25 s, 64 frames: wheel pixels inside any text/panel box, both bands and the leader labels) | 1 → **0 crossed** |
| Every-frame model check (`tools/checkframes.mjs`, 384 frames) | 1 → turned max 0°, cross-ring 90° ± 1e-14, distance/stride = 3.7699 m = π·R |
| Live-page drives (tour → A2 → A3 east + north → A4 lift + orbit) | 2 (no page errors) |
| Full film captures | 2 (second after adding the label backing) |
| Score renders | 1 |
| Final verification: frames from the encoded MP4 read (9 full frames, 4 crop sheets at 100 %, 3 consecutive frames, the skill's 12-frame beat sheet) | 1 pass |

## Render cost

Capture at CSS 1080 × 1350, device-pixel-ratio 1.6 (1728 × 2160 supersample), screenshot + x264 crf 14 per chapter,
then joined and scaled to 1080 × 1350 (Lanczos, crf 17). From `out/film/capture-log.tsv` (final run):

| Chapter | Content | Frames | Seconds | s / frame | Blender running at start |
|---|---|---|---|---|---|
| A1 | 1 wheel (1,672 eye instances ×4 meshes), transmission, sky | 96 | 18.7 | 0.194 | no |
| A2 | 1 wheel close, eyes opening + gaze | 96 | 19.9 | 0.208 | no |
| A3 | 1 wheel gliding, floor compass/path | 96 | 20.0 | 0.208 | yes |
| A4 | 4 wheels (3,344 eyes), fire, lightning | 96 | 23.7 | 0.247 | yes |
| **Total** | | **384** | **82.3 s** | mean 0.214 | |

Whole pipeline (`time tools/film.sh`: 4 captures + join/scale + mux): **1 min 33 s** (first run, with Blender running
throughout: 2 min 09 s, 0.215-0.378 s/frame). Score synthesis: 8.2 s. One review still: ~1 s after page load
(~1.2-1.5 s load, the eye layout is computed at load).

## Outputs

| File | Size | Format |
|---|---|---|
| `out/part-a-v2.mp4` | 10.8 MB (10,817,637 B) | H.264 1080 × 1350, 24 fps, 384 frames, 16.000 s; AAC 256 kb/s; **−14.0 LUFS** integrated, LRA 2.4 LU |
| `out/part-a-v2-silent.mp4` | 10.3 MB (10,314,290 B) | same picture, no audio |
| `out/part-a-v2-score.wav` | 3.07 MB (3,072,044 B) | 48 kHz stereo, 16.000 s, −14.0 LUFS, true peak −7.5 dBFS |
| `out/part-a-v2-live.html` | **851 KB (871,895 B)**, one file, offline | **interactive: yes** |
| `teardown-out/dist/part-a-film.html` (capture page) | 855 KB | |

Live page (1600 × 1000 window, headless Chrome on the M4, Blender rendering at the same time): tour ~26-35 fps, in
control ~24-26 fps; the quality governor drops a tier below 30 fps. Not tested on an integrated-GPU laptop or a phone;
expect it to be heavy there (≈ 9 M triangles a frame with the four wheels).

Assets downloaded: **none** (see ASSETS.md).

## Things that failed and were rejected (8)

1. Shader compile error: my crystal shader's variable `n` collided with three.js's transmission code. Renamed
   (q-prefixed).
2. Crystal's base `emissive` left white: every rim glowed white and bloom whited out the frame (iter1).
3. First sky: the cloud noise was scaled for a wide lens; at 22° it was one blurred cream wash, and too bright (iter2,
   probe). Rewritten with 6-8× higher frequency and darker values; a wide-fov probe confirmed the layout.
4. Camera target offset with the wrong sign: the wheel sat low and entered the bottom band (iter2).
5. Eye almond along the ring tangent: on the upright arcs the eyes stood vertical and read as goggle eyes; with the
   orientation turned on the side faces the count fell to 793 → spacing 1.34 → 1.29 to get back to 836.
6. **Lid mounds wound inward and back-face culled**: the eyes showed as bare white balls ("pearls", crop 1-3). Found
   on the 100 % crop; winding reversed.
7. A3: the floor's gold compass ran under the quote band; now clipped to the stage band in screen space.
8. Panel text overflow (A2 gaze line, A3 distance line) and the A1 scale diagram running into its title; shortened /
   resized. Gold label subtitles weak over bright cloud: dark backing added (second capture).

## What looks wrong (honest)

- **Eyes at film distance are small**: 836 eyes on a 2.4 m wheel are 6-40 px wide in the 1080 frame (A2 is the
  closest shot). At 100 % they read as almond eyes with gold lids and warm irises, but there is no corneal
  refraction or wet highlight like the Blender macro; in A4 (four wheels at 31 m) they are gold flecks.
- **The crystal is a WebGL approximation**: transmission + attenuation + emissive amber, not subsurface. Near the
  crossings the stone goes pale cream-gold (as in the Blender stills, but flatter); sun glints on the clearcoat and
  the gold collars bloom into small star-like flares, busiest in A4.
- **The sky is procedural**: the storm bank reads as a dark ragged band with gold rims, but it has no volume, the rims
  are thin, and the gaps under the bank are a pale cream that can look washed out. Clouds drift very slowly.
- **The floor is generic polished slate**; it fades into a flat beige haze band at the horizon (A1/A2/A4).
- **A3 rolling**: the wheel hovers 0.30 m and glides; the roll is only seen in the ring's angle, the eyes' travel and
  the gold highlight on the rolling ring. During the east stride the roll term (−180° over 1.5 s) briefly cancels
  ring A's +25°/s spin, so it looks momentarily still, then turns the other way. Correct for the model, maybe odd.
- The A3 → A4 chapter change fades the overlay out and in (12.0-12.5 s) while the camera pulls back; for ~0.4 s
  the frame has almost no text. The three hidden wheels appear instantly at 12.9 s (the isolate toggled off, as v1).
- The fire (the spirit) in A4 is v1's soft sprite with short lightning; next to four glowing wheels it is not very
  distinct.
- Live page frame rate measured only on the M4 while Blender was rendering (24-35 fps); unknown on weaker GPUs.
- The score is v1's Part A material (pad, bells, stride rolls, eye shimmer, lift air) re-timed; not re-composed.
