# Part A v2: "The Wheels of Ezekiel", explain the parts (teardown style, Three.js), on the v6 wheel

Part A of the shared scenario (`../SCENARIO.md` A1-A4) rebuilt on the **new wheel design** of
`../ezekiel-ophanim-v6/` (FIDELITY.md, stills 03 and the contact sheet). One Three.js model drives the film, the live
page, every number on screen and the score. Copied from `../ezekiel-encounter-teardown/` (Track A v1) and changed. The
v1 folder, every `ezekiel-ophanim-*` folder and `ezekiel-encounter/` were **not modified** (the DR text was copied
from `ezekiel-encounter/text/`). Nothing posted, uploaded or committed.

## Deliverables (`out/`)

- `part-a-v2.mp4`: 1080 × 1350, 24 fps, 16.000 s (384 frames), H.264 + AAC score, −14.0 LUFS.
- `part-a-v2-silent.mp4`: the same picture, no audio (for your own mix).
- `part-a-v2-score.wav`: the procedural score alone, 48 kHz stereo, 16.000 s, −14 LUFS, true peak −7.5 dBFS.
- `part-a-v2-live.html`: the live page, **851 KB (871,895 B)**, one offline file, interactive (auto tour, chapters
  A1-A4, the spirit's four directions, lift, eyes, isolate, pause, orbit, zoom, keys; 25 s idle hands back to the tour).
- Review material: `representative-frames.png`, `spin-consecutive.png`, `crops-*.png` (100 % crops from the final
  MP4), `part-a-v2_sheets/` (the skill's sheet of the encoded video), `mask/` + `mask-sheet.png`, `live-*.png`.

## Chapters (4 s each, Douay-Rheims, drbo.org numbering)

| | Title | Quote band (as in `text/ezechiel_1-2_douay-rheims.txt`) |
|---|---|---|
| A1 1:16 | A wheel in a wheel | "their appearance and their work was as it were a wheel in the midst of a wheel" |
| A2 1:18 | Full of eyes round about | "the whole body was full of eyes round about all the four" |
| A3 1:17 | They turned not | "When they went, they went by their four parts: and they turned not when they went" |
| A4 1:20 | The spirit of life was in the wheels | "the wheels also were lifted up withal, and followed it: for the spirit of life was in the wheels" |

Typography note: the drbo text has a space before the colon in 1:17 ("four parts : and"); it is the anchor of the
drbo footnote [17], so it was dropped. Every other character is as in the file. The A4 title is long; it is shrunk to
fit one line (it lands at ~74 px instead of 86 px).

## What changed against v1

1. **The wheel is the v6 wheel.** Thin, flat, tall rims (band 0.30 m tall × 0.115 m thick at R 1.2 m, fillet 22 mm;
   v1 was 0.27 × 0.15), the two rings crossed at 90°, **gold-bronze bearing collars** at the two crossings, and a
   translucent crystal: hue field sea-green → aquamarine → clear in each ring's own frame (it turns with the ring),
   MeshPhysical transmission with a teal attenuation, and **amber fire inside the stone strongest at the crossings**,
   fixed in the wheel's body (the rings spin through it), plus a soft teal inner glow, an amber lamp at each wheel's
   centre and additive glow at the crossings, all humming on v4's 3.3 s / 1.15 s pulse.
2. **836 eyes per wheel, 3,344 for the four** (v1: 86 / 344). Layout ported from the Blender v4 algorithm (dart
   throwing on the band's surface, largest first: 30 large r 50-72 mm, 100 medium r 30-50 mm, the rest r 21-32 mm,
   on every flat face of both rings: both sides, outer and inner face). Uncapped it places 835-844; it is capped at
   418 per ring = 836, asserted at load. Two changes from Blender: the spacing factor is **1.29** (Blender 1.34),
   because on the tall side faces the almond now lies **across** the band, so the eyes on the upright arcs we mostly
   see are level (with the Blender orientation they stood vertical there and read as "goggles"); on the narrow outer
   and inner faces it lies along the ring. Each eye: an instanced eyeball front (warm iris: amber / hazel / brown /
   grey-green), a lid that is a **mound of the stone** round an almond opening, a **gold bead on the lid margin**, and
   a blink cover (an upper-lid strip posed in the vertex shader). Calm resting droop (16 % of the opening).
   **Eyes track a target** (the lens in A2-A3, the spirit's fire in A4; at most ±29° in the lids, an eye on a face
   turned away cannot) and **blink** (each on its own 3.2-7.5 s period, 0.32 s). In A1 they are shut; in A2 they open
   in a ripple round ring A then ring B (the "EYES OPEN" counter runs 0 → 836).
3. **The rings spin continuously on their own axes**: ring A (faces N/S) about z, ring B (faces E/W) about x, wheel 1 at
   25 / 37 °/s, the others ±26-34 °/s with different start phases, so **the four are out of phase** (the A4 panel
   shows all eight angles). The body never yaws. **Interpretive**: the text does not say the rings spin; v4/v5 chose it
   from 1:20 "the spirit of life was in the wheels" (a gyroscope with a fixed frame, never a tumble). The live page
   says so too.
4. **A3 still travels without turning**: a stride is half a turn, π·R = 3.77 m, towards one of the four parts. The
   body glides; the ring whose plane is the direction of travel gets the rolling term s/R on top of its spin (east →
   ring A −180°, north → ring B −180°, sign = rotation axis up × direction); the other ring only keeps spinning.
   **"Turned" is measured on the posed scene** (body yaw + the formation's heading from wheel 2 → wheel 1) and is
   0.0° on all 384 frames (`tools/checkframes.mjs`). The wheels hover 0.30 m (v4: they go with the creatures), so the
   spin and the roll term never fight a ground contact.
5. **Light**: a procedural sky in the Blender v6 palette (deep-blue zenith, small gold-lit cumulus, a dark storm bank
   on the horizon with gold rims and amber fire in its folds, the low sun WNW just outside the left edge of every
   camera; they all look NNW, like v6's VIEW_AZ 344), a dark polished slate floor fading into warm haze, a
   sunrise-warm key from the front-left (it casts the shadows), the sun as a gold rim, a second gold rim from
   behind-right, the wheels' own amber lamps, a PMREM environment from the same sky, soft UnrealBloom (0.32), ACES.
   A1/A2 use a low camera (3° and 2° below the wheel's centre) so the bank and the sky stand behind the wheel.
6. **Caption bands as before** (top 0-270 px, bottom 985-1350 px), re-skinned for the sky: ivory type on dark scrims,
   dark-glass panels, one gold accent. The floor's gold compass/path is clipped in screen space to the stage band.
   Leader labels in the stage band have a dark backing.

## Live panels (all read from the posed scene, `shared/film.js readouts()`)

- A1: cross-ring angle 90.0° with plan/elevation (spin markers move); ring angles live ("RINGS · OWN AXES": A, B,
  25/37 °/s, ⌀ 2.40 m, rim 30 × 11.5 cm); **scale: the 2.40 m wheel beside a 1.7 m man** (a bar, not a figure) =
  1.4 men, Part B ×33.3 → ⌀ 80 m.
- A2: eyes open n / 836, 3,344 in the four, blinking now; the band unrolled (836 dots, gold = facing the lens); gaze
  count within 3° of the lens.
- A3: plan/elevation with the rolling ring in gold; strides 0.00 → 2.00, distance (3.77 m per stride = π·R, checked
  on every frame), ring A/B angles, roll added; turned 0.0° with the compass.
- A4: lift chart (spirit leads, wheels follow, to 1.00 m), spirit height, spread of the four 0 mm, turned 0.0°; the
  four wheels' ring angles.

## Files

`shared/model.js` (numbers, band section, eye layout, blink, act, ring angles, sun) · `shared/wheel.js` (band,
collars, eyes, mounds, beads, covers, crystal/gold/iris shaders, posing) · `shared/stage.js` (sky, floor, lights,
post, mask mode) · `shared/script.js` (chapters, act, cameras, `viewAt`) · `shared/overlay.js` · `shared/film.js`
(readouts, film runner) · `shared/live.js` · `shared/score.py` · `shared/geo.js` (taperTube, from v1) ·
`tools/film.sh` (chapter-by-chapter capture, one Playwright at a time, silent + scored) · `tools/maskcheck.mjs`
(caption bands and labels vs wheel pixels) · `tools/checkframes.mjs` (turned / cross / stride on every frame) ·
`tools/probe.mjs` (debug stills/crops) · `tools/shoot-live.mjs` (drives the live page).

Rebuild: `node gen-timeline.mjs && node ~/.claude/skills/teardown/sims/build.mjs ./part-a-film ./part-a-live &&
python3 ~/.claude/skills/teardown/run_sfx.py shared/score.py && ./tools/film.sh` (it sets CHROMIUM to the cached
Chrome for Testing 1248 itself).
