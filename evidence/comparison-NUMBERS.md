# NUMBERS — every figure shown in comparison-v2.mp4, with source

Paths below are relative to the private project's root. Every number is copied verbatim from the
FINAL tracks' own `METRICS.md` / `NOTES.md` / `FIDELITY.md`, or measured directly on the files named
(ffprobe/ls, noted as such). No source directory was modified to build this video; `comparison-v2/`
contains only new files. The old `comparison/` folder and `article/ARTICLE.md` were not touched.

## Which clips were used

| Pair | Three.js (left) | Blender (right) |
|---|---|---|
| 1 — "A wheel in a wheel" (Ez 1:16) | `ezekiel-part-a-v2/out/part-a-v2.mp4` 0:00–0:04 (chapter A1) | `ezekiel-ophanim-v7/out/final/B1.mp4` (wide reveal) |
| 2 — "Full of eyes round about" (Ez 1:18) | same file, 0:04–0:08 (chapter A2) | `ezekiel-ophanim-v7/out/final/B3.mp4` (macro eyes) |
| 3 — "The man and the wheels" (Ez 2:1) | same file, 0:12–0:16 (chapter A4) | `ezekiel-ophanim-v7/out/final_v2/B5.mp4` (prostrate, re-shot v2) |

Chapter boundaries: `ezekiel-part-a-v2/NOTES.md:19-26` ("Chapters (4 s each)" table — A1 1:16, A2 1:18,
A3 1:17, A4 1:20). B-shot identity and the final_v2 preference for B5: `ezekiel-ophanim-v7/METRICS.md`
("final_v2 redo" section) and `final-film/BUILD.md` ("B-shot source selection").

Verse for pair 3: Ez 2:1 ("I fell upon my face"), not 1:28, per `ezekiel-ophanim-v7/FIDELITY.md`
("Round 7" table, B5 row: `TEXT 2:1 (DR) "I fell upon my face"`) and `final-film/SHOTLIST.md`
(explicit note: "this file's chapter 2 — 'I fell upon my face' lands at 2:1, not 1:28").

Both Three.js segments and both Blender clips are looped (ffmpeg `-stream_loop -1`, exact source
frames, no reversal/retiming/speed change) to fill the 12 s pair duration so the numbers strip has
time to be read; nothing about the source content was altered.

## Title card

| On screen | Value | Source |
|---|---|---|
| Track A | "interactive · 836 eyes/wheel · 36 min build" | eyes: `ezekiel-part-a-v2/NOTES.md:41` ("836 eyes per wheel, 3,344 for the four"); build: `ezekiel-part-a-v2/METRICS.md` wall-clock table, "Elapsed \| 36 min" |
| Track B | "Cycles · 504 frames · 4.13 h render" | `ezekiel-ophanim-v7/METRICS.md` header ("B1-B5, 21 s, 504 frames") and seconds-per-frame table, "All" row: "504 (+4 re-rendered) \| 29.3 \| \| 4.13 h render, 5.3 h wall" |

## Pair 1 — "A wheel in a wheel" (Ez 1:16)

| Side | Stat | Value | Source |
|---|---|---|---|
| Three.js | BUILD | 36 min | `ezekiel-part-a-v2/METRICS.md` wall-clock table |
| Three.js | RENDER (A1, 96 fr) | 18.7 s | `ezekiel-part-a-v2/METRICS.md` render-cost table, row A1: "96 \| 18.7 \| 0.194" |
| Three.js | FILM | 10.8 MB | `ezekiel-part-a-v2/METRICS.md` outputs table: "out/part-a-v2.mp4 \| 10.8 MB (10,817,637 B)" |
| Three.js | LIVE PAGE | 851 KB | `ezekiel-part-a-v2/METRICS.md` outputs table: "out/part-a-v2-live.html \| 851 KB (871,895 B)" |
| Three.js | INTERACTIVE | YES | same row, "interactive: yes" |
| Blender | RENDER (B1, 120 fr) | 58.4 min | `ezekiel-ophanim-v7/METRICS.md` seconds-per-frame table, row B1: "120 \| 29.2 \| 23.7-36.3 \| 58.4 min" |
| Blender | FILE | 8.9 MB | `ezekiel-ophanim-v7/METRICS.md` outputs table: "out/final/B1.mp4 \| 8.9 MB" |
| Blender | FINAL RENDER TOTAL | 4.13 h (504 fr) | same METRICS.md, "All" row (see title card above) |
| Blender | LOOK-DEV ROUNDS | v3–v7 (5) | directory listing: `ezekiel-ophanim-v3/`, `-v4/`, `-v5/`, `-v6/`, `-v7/` each with their own METRICS.md; round numbering confirmed in `ezekiel-ophanim-v7/FIDELITY.md` ("Round 3" … "Round 7" section headers) |
| Blender | INTERACTIVE | NO | no live/interactive output exists for this track (no `.html` in `ezekiel-ophanim-v7/out/`) |
| both | footer: 836 eyes/wheel, 3,344 in the four | `ezekiel-part-a-v2/NOTES.md:41` and `ezekiel-ophanim-v7/FIDELITY.md` ("v4 note": "836 eyes per wheel (3,344 for four)") |

## Pair 2 — "Full of eyes round about" (Ez 1:18)

| Side | Stat | Value | Source |
|---|---|---|---|
| Three.js | BUILD | 36 min | as above |
| Three.js | RENDER (A2, 96 fr) | 19.9 s | `ezekiel-part-a-v2/METRICS.md` render-cost table, row A2: "96 \| 19.9 \| 0.208" |
| Three.js | FILM | 10.8 MB | as above |
| Three.js | EYES OPEN LIVE | 0 → 836/wheel | `ezekiel-part-a-v2/NOTES.md:50-51` ("the 'EYES OPEN' counter runs 0 → 836") |
| Three.js | INTERACTIVE | YES | as above |
| Blender | RENDER (B3, 96 fr) | 27.7 min | `ezekiel-ophanim-v7/METRICS.md` seconds-per-frame table, row B3: "96 \| 17.3 \| 14.8-20.0 \| 27.7 min" |
| Blender | FILE | 3.7 MB | `ezekiel-ophanim-v7/METRICS.md` outputs table: "out/final/B3.mp4 \| 3.7 MB" |
| Blender | MEAN COST | 17.3 s/frame | same row as render time above |
| Blender | SHOT | macro, eyes turn | `ezekiel-ophanim-v7/METRICS.md` shot table label ("B3 macro, eyes turn") |
| Blender | INTERACTIVE | NO | as above |
| both | footer | same as pair 1 | same sources |

## Pair 3 — "The man and the wheels" (Ez 2:1)

| Side | Stat | Value | Source |
|---|---|---|---|
| Three.js | BUILD | 36 min | as above |
| Three.js | RENDER (A4, 96 fr) | 23.7 s | `ezekiel-part-a-v2/METRICS.md` render-cost table, row A4: "96 \| 23.7 \| 0.247" |
| Three.js | FILM | 10.8 MB | as above |
| Three.js | SCALE | ⌀2.40 m → ⌀80 m | `ezekiel-part-a-v2/NOTES.md:77` ("scale: the 2.40 m wheel beside a 1.7 m man ... Part B ×33.3 → ⌀ 80 m") |
| Three.js | INTERACTIVE | YES | as above |
| Blender | RENDER (B5 v2, 96 fr) | 48.4 min | `ezekiel-ophanim-v7/METRICS.md` "final_v2 redo" section: "B5 v2 render ... 96 frames, mean 30.3 s/frame (24.8-40.3), 48.4 min render" |
| Blender | FILE | 3.6 MB | same section: "out/final_v2/B5.mp4 (3.6 MB)" |
| Blender | MEAN COST | 30.3 s/frame | same line as render time above |
| Blender | SHOT | prostrate, re-shot v2 | `ezekiel-ophanim-v7/METRICS.md` "final_v2 redo" ("B5 v2 look-dev (new 'lying' pose...)"); reason for the reshoot: original B5 "reads as a small grey lump" (`METRICS.md` "Honest flaws") |
| Blender | INTERACTIVE | NO | as above |
| both | footer | same as pair 1 | same sources |

## Closing card

| On screen | Value | Source |
|---|---|---|
| "final-film-en.mp4 · 41.5 s" | 41.5 s | measured directly: `ffprobe -show_entries format=duration final-film/final-film-en.mp4` → `41.500000`; also stated in `final-film/SHOTLIST.md:3` ("41.5 s total") |
| 3 thumbnails | frames at 0:01, 0:19, 0:36 of `final-film/final-film-en.mp4` | extracted directly with ffmpeg (`-ss 1/19/36 -frames:v 1`); these are hook, B1, and B5 — the same clips as pairs 1 and 3 of this video, plus the opening hook card |
| "Track A — Three.js: part-a-v2, 36 min build, 10.8 MB, interactive (851 KB live page)" | as above | `ezekiel-part-a-v2/METRICS.md` |
| "Track B — Blender: ophanim v7, 504 frames, 4.13 h render, 5 look-dev rounds (v3–v7)" | as above | `ezekiel-ophanim-v7/METRICS.md` |
| "Shared spec: 4 wheels · 836 eyes/wheel, 3,344 total · Douay-Rheims Ezekiel 1–2" | as above | `SCENARIO.md` (4 wheels, per-track scenario) + eye count sources above |
| Credits line | teardown skill by elvarofficial (MIT) · Poly Haven assets (CC0) · Douay-Rheims (public domain) | `~/.claude/skills/teardown/LICENSE` (MIT); `ezekiel-encounter/ASSETS.md` (Poly Haven, CC0, full list); Douay-Rheims is public domain (drbo.org) |

## Container (measured directly on this file with ffprobe)

- `out/comparison-v2.mp4`: H.264 High profile, 1080×1350, yuv420p, 24 fps, 51.000000 s, 1224 frames,
  no audio stream (silent — see "Audio decision" below), bit rate 4.10 Mb/s, size 26,127,439 B
  (26.13 MB, under the 40 MB budget). `ffprobe -show_format -show_streams out/comparison-v2.mp4`,
  run directly, see raw output in the delivery report.

## Audio decision

Shipped silent. The brief allowed either a quiet bed (reusing `final-film/work/` stems, −14 LUFS) or
silence. The only stems on disk (`audio-partb.wav`, 25.3 s; `audio-hook.wav`, 2.9 s; `mastered.wav`,
41.8 s) are timed to the combined film's own cut points (hook/Part A/B1–B5 at specific timecodes) and
none match this video's different pacing (6 s title + three 12 s pairs + 9 s closing = 51 s); laying
one under mismatched visuals would plant swells/hits at the wrong moments. Silence was judged more
honest than a bed that implies sync that isn't there. No audio-related number is shown on screen.

## Known minor artifact (disclosed, not hidden)

In pair 1 and pair 3, a short gold leader-line stub (from the source film's own on-screen label,
e.g. "RING A" in A1) is visible for a few pixels at the left edge of the Three.js crop — it is a
leftover of the source video's own baked-in HUD graphics, not added by this build, and carries no
legible text. Pair 2's crop was shifted right (x-offset 300 instead of 270) specifically to clear a
label box ("EYE / GOLD LIDS · 1:18", full-frame x 55–295 y 320–385 in `ezekiel-part-a-v2/out/part-a-v2.mp4`)
that otherwise intruded on the first ~3 frames of a few corners; verified clear in the rebuilt frames.

## Numbers NOT sourced / not shown

- None omitted silently. No number appears on screen that isn't a direct quote from the files above
  or a direct ffprobe/ls measurement of a named file. The video does not display aggregate look-dev
  timings across all five Blender rounds (v3–v7) because `ezekiel-ophanim-v5/METRICS.md` and
  `ezekiel-ophanim-v6/METRICS.md` do not state a single "active working time" figure the way v3 and
  v4 do (v3: "~1 h 52 min + ~40 min"; v4: "~2 h 40 min over four sessions") — see the article's build
  section, which says "not logged" for v5/v6 active time rather than guessing or summing incomparable
  numbers.
