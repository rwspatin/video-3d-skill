# METRICS — ophanim v7: the FINAL Part B (B1-B5, 21 s, 504 frames, 1080 x 1350, 24 fps)

Machine: Apple M4, 16 GB, Blender 5.2.3 LTS, Cycles Metal, OIDN. One Blender process at a time; the final render ran
detached (`nohup tools/render_final.sh &`) with its own log `out/final/render.log`, in 8-frame chunks of fresh
processes, memory-safe defaults (persistent data off, no deformation blur).

## Wall clock (`date`)

| | |
|---|---|
| Start (v7 copied from v6) | 2026-11-04 14:59:35 -03 |
| Phase 1 (look fixes, 3 test stills, cost bisect) | 14:59 -> ~16:00, then a usage-limit pause; cost re-measured 18:50-19:02 |
| Final render | 2026-11-04 19:03:14 -> 2026-11-05 00:22:08 (**5 h 19 min wall**, incl. ~50 min lost to a hung chunk) |
| End | 2026-11-05 ~00:30 -03 |

## Phase 1 — cost findings

- At first the film settings cost **222 s/frame (75 %, 12 spp)**. Two causes:
  1. **External GPU load** (another process held the GPU at 76 % with no Blender running; v6's own test frame went
     from 37 s to 121 s). It went away by 18:50 (GPU 3 %).
  2. **Per-frame scene export, not pixels**: at 25 % / 6 spp B1 still took 35-50 s per frame. Coarsening the ridge /
     far terrain meshes (`TERRAIN_RES` 0.55, `LEDGE_RES` 0.7; visually identical, `out/tests/cmp_terrain.png`) cut a
     B1 frame from ~55 s to **26 s** at 75 %.
- Persistent data ON was tried again: frames climbed 32 -> 73 s within a chunk (no gain). Kept off.

## Final render settings

75 % (810 x 1012) -> Lanczos upscale to 1080 x 1350 (ffmpeg), 16 spp max, adaptive threshold 0.12, OIDN, clamp
indirect 3 / direct 12, motion blur 0.5 (object only), 8-frame chunks.

## Seconds per frame (render only, from `out/final/frames_log.jsonl`)

| Shot | Frames | Mean s/frame | Min-max | Render time |
|---|---|---|---|---|
| B1 wide, descend + push-in | 120 | 29.2 | 23.7-36.3 | 58.4 min |
| B2 over the shoulder | 96 | 40.6 | 25.3-130.5 | 65.0 min |
| B3 macro, eyes turn | 96 | 17.3 | 14.8-20.0 | 27.7 min |
| B4 low, half-turn roll | 96 | 27.2 | 20.9-36.0 | 43.5 min |
| B5 prostrate, still wheels | 96 | 29.8 | 25.4-36.7 | 47.7 min |
| **All** | 504 (+4 re-rendered) | **29.3** | | **4.13 h render, 5.3 h wall** |

B2's spike (65-130 s/frame, frames ~60-75) was again external load: two Chrome processes at ~100 % CPU each, the
Metal compiler service at 261 %, GPU 84 %, swap 9 GB. Chunk 73-80 hung (Blender paged out); the job was restarted
(the restart line in the log is not mine — another session restarted it at 21:59; there was never more than one
Blender running). The restart resumed at chunk 73; frames 68-77 are continuous (mean abs diff 2.9-3.2, no jump).

## Outputs

| File | Size | Format |
|---|---|---|
| `out/final/B1.mp4` | 8.9 MB | H.264, 1080 x 1350, 24 fps, 120 frames, 5.000 s, **no audio** |
| `out/final/B2.mp4` | 5.4 MB | 96 frames, 4.000 s, no audio |
| `out/final/B3.mp4` | 3.7 MB | 96 frames, 4.000 s, no audio |
| `out/final/B4.mp4` | 2.3 MB | 96 frames, 4.000 s, no audio |
| `out/final/B5.mp4` | 5.7 MB | 96 frames, 4.000 s, no audio |
| `out/final/Bx/png/f_0001..` | 504 PNG | 1080 x 1350 (upscaled), for retiming |
| `out/final/Bx/raw/` | 504 PNG | 810 x 1012 native renders |
| `out/stills/phase1-test-50pct-{hero,low,macro}.png` | | the 3 Phase-1 test stills (540 x 675) |

Total `out/final`: 1.4 GB.

## Verification

First/middle/last frames of every shot looked at (`out/tests/final_B{1..5}_3.png`); B2 continuity across the restart
checked numerically. Not done: frame-by-frame review of all 504 frames, a full-resolution flicker check on every shot.

## Honest flaws

- **God rays**: still faint; the sun now sits just inside the left edge behind its own cloud card, but it shows as a
  broad milky haze glow at the left of B1/B2/B4/B5 rather than distinct shafts through the cloud.
- **Cloud**: a backdrop plate (as decided); fine with the static/slow cameras used.
- **Crystal fire**: the amber veins are visible (macro, close wheels) but at the wide framings the wheels read as
  mottled teal/gold rather than glowing from within.
- **B2**: the wheels do not "fill the sky" (the man was made smaller as asked, which also pushed the wheels smaller);
  a background wheel is cut by the right edge.
- **B3**: the eyes turn toward the man, but at the end the irises are half under the lids — reads as a sideways glance,
  slightly shifty, more than as awe.
- **B4**: the rolling half turn reads (ring A visibly turns over, heading constant), but the man is cut by the right
  frame edge, and the wheel starts washed out in the sun-side haze.
- **B5**: the fall is **not animated** (starts prostrate and holds, as allowed); at this distance the prostrate man
  reads as a small grey lump — not clearly a man on his face. Needs a closer, lower angle or a better body.
- Phase-1 test stills were at 50 %; no full-resolution stills of v7 were rendered (the frames are the deliverable).
- Prismatic halo at the crossings: not built.

## final_v2 redo (2026-11-05)

| | |
|---|---|
| B5 v2 look-dev (new `lying` pose, 2 cloth sims ~75 s each, 3 test frames at 50 %) | 00:20 -> 00:39 |
| B5 v2 render | 00:39:58 -> 01:35:26 — 96 frames, **mean 30.3 s/frame** (24.8-40.3), 48.4 min render |
| B4 v2 framing tests (2 at 25 %; the first camera move landed behind a boulder, black frames) | 01:36 -> 01:38 |
| B4 v2 render | 01:38:08 -> 02:29:52 — 96 frames, **mean 28.8 s/frame** (23.8-35.9), 46.0 min render |

Watchdog never fired (0 restarts). Outputs: `out/final_v2/B5.mp4` (3.6 MB) and `out/final_v2/B4.mp4` (2.3 MB), both
H.264 1080 x 1350, 24 fps, 96 frames, 4.000 s, no audio; PNG sequences in `out/final_v2/B5/png/`, `B4/png/` (raw 75 %
renders in `raw/`). The original `out/final/B4.mp4` and `B5.mp4` are untouched.

Still weak: in B5 the mantle is pale and flat, so he reads as a person under a spread sheet (outstretched arms not
readable through it); in B4 the man is now in frame but small at the right, and the haze glow at the left remains.
