# Assembling a final film from heterogeneous pieces

Lessons from the final-assembly script of "The Wheels of Ezekiel" (write-up:
https://renanspatin.com/en/blog/ofanim-ezequiel), which combines a Three.js/Playwright console film
(Part A), five Blender/Cycles shots (Part B, B1-B5), and Playwright-rendered caption/title cards into
one muxed MP4 in two languages. The script itself isn't included here; its own build log
(`evidence/assembly-BUILD.md`) is, and most citations below point into that. The build never modifies
any source track — it only reads from the Part A and Part B output folders and writes under its own
output directory (source: `evidence/assembly-BUILD.md:12-15`).

## Caption overlays: transparent PNG + alpha-fade composite

Captions are rendered once as transparent 1080×1350 PNGs with Playwright + a cached Chromium, reusing
the same fonts and palette as the upstream Part A overlay (Cormorant Garamond italic 500 / normal 600,
JetBrains Mono 600, `#f6eedf` ivory, `#ffd27a` gold accent) — base64-embedded fonts read once into
`work/fonts_b64.json` so the render is deterministic and offline (source: `evidence/assembly-BUILD.md:31-36`).
They are composited onto the B-shot video with ffmpeg's `overlay` filter, fading the caption on its
**alpha channel** (0.4 s in/out) — not `drawtext` — specifically so the real glyphs render, not a
built-in font substitute (source: `evidence/assembly-BUILD.md:40-45`).

### The `-loop 1` bug

```bash
ffmpeg -y -i "$SRC" -loop 1 -i "captions/$S.png" \
  -filter_complex "[1:v]format=rgba,fade=t=in:st=0:d=0.4:alpha=1,fade=t=out:st=${FO}:d=0.4:alpha=1[ov]; \
                   [0:v][ov]overlay=0:0:format=auto,format=yuv420p[v]" \
  -map "[v]" -t "$D" ...
```

`-loop 1` on the still-image input is **not optional**. Without it, ffmpeg decodes a single frame of
the still at its own `pts=0` — which is the very first instant of the alpha fade-in — so the caption
renders fully transparent for the **entire** clip, every frame, because there is no second frame to
advance the fade. The symptom is silent: ffmpeg exits 0, the output file is a plausible size, and the
caption is simply invisible throughout. This bit the first build and was only caught by reading an
actual decoded frame of the composited output, not by trusting the exit code (source:
`evidence/assembly-BUILD.md:43-45`). **Verification rule that generalizes:** a zero-exit-code ffmpeg run on a
filter graph with a still-image input and a time-based fade is not evidence the fade is doing
anything — read a frame.

## Hard cuts vs. dissolves between shots

Part A → B1 **crossfades** (0.5 s `xfade`). Every other B-to-B transition (B1→B2→B3→B4→B5) is a
**hard cut** via `concat`, not a dissolve, even though the brief allowed a 0.25-0.4 s dissolve
(source: `evidence/assembly-BUILD.md:60`). Reason: each B-shot carries its own caption block (different
title, different verse quote). A 0.3 s dissolve was tried first between every B-shot; during the
dissolve window the outgoing shot's caption and the incoming shot's caption are both partially opaque
and literally overlap — two paragraphs of text double-exposed, unreadable (source:
`evidence/assembly-BUILD.md:62-65`). Part A→B1 can still crossfade because Part A's **own** caption has
already faded out by the time that dissolve starts — checked at the actual crossfade frame, not
assumed (source: `evidence/assembly-BUILD.md:65-68`; a supporting frame capture from the original
build session is not reproduced here — unverified beyond the text).

**Rule:** a dissolve is safe between two shots that have no on-screen text overlapping in time at the
cut point. If both sides carry independent caption blocks, cut hard.

## Keeping caption bands clear of the subject (mask test)

The Blender B-shot frames do **not** keep the wheel/figure confined to any fixed top/bottom band — so
each shot's caption layout was chosen by reading actual rendered frames, not assumed from camera
parameters (source: private project document, excerpt below — a per-shot layout log, not included
here, states each shot's reserved caption band and why). Each of B1-B5 got its own layout decision
(e.g. one shot moves the whole caption stack to the bottom band because the eye texture fills the
entire top band edge-to-edge in both the first and last frame of that shot — source: private project
document, excerpt above). After a re-shoot of two of the five shots, the layout was **re-verified
against the new footage**, not left as-is on the assumption that "it worked before" (source: private
project document, excerpt above). Verification method: composite the caption PNG over the actual
first/mid/last frame of each shot, including both hard-cut boundaries into and out of the re-shot
shots, and read the result from the **final muxed MP4** (source: private project document, excerpt
above; the frame captures used for that check are not reproduced here — unverified beyond the
description).

## Hook/end card variants without re-rendering anything upstream

`HOOK_VARIANT=<name> ./build.sh` changes only the hook and end card **text**, never the Part A/B
footage, never the audio mix. Mechanism (source: `evidence/assembly-BUILD.md:116-126`; the script
itself isn't included here, but its own build log describes the mechanism in full):

1. The variant branch is checked at the very top of the script, **before** the normal pipeline's
   "sources" step.
2. If `work/core.mp4` (Part A + captioned B1-B5, already concatenated) or `work/mastered.wav` (the
   final audio mix) don't exist yet, it exits with an error telling you to run `./build.sh` with no
   flag first — it never tries to regenerate them.
3. It generates just that variant's two card PNGs (`gen-cards.mjs` renders every variant's copy into
   distinct filenames up front, so one variant's run can never overwrite another's source PNG), encodes
   just the two new hook/end clips, and muxes them with the **cached** `core.mp4` and `mastered.wav`.
4. It writes `final-film-<lang>-<variant>.mp4` — a name distinct from the base `final-film-<lang>.mp4`
   and every other variant — then exits before reaching the normal 6-step pipeline.

This was verified, not assumed: the project hashed every prior output file with `shasum -a 256` before
and after running a variant, and confirmed they were byte-identical (source: `evidence/assembly-BUILD.md:123-124`).
**Generalizable pattern:** when a downstream asset only changes a small text/graphic layer, cache the
expensive intermediate (the fully assembled "core" before text/branding) once, and make every variant
branch early, reuse the cache, and write to a variant-specific output filename — never a shared one.

## Audio: reuse + two-pass loudness normalization

Two new stems are synthesized with the **same** synthesis kit Part A's own score uses
(`~/.claude/skills/teardown/sfx/`: `pad`, `chime`, `bandnoise`, plus `drone`/`shimmer`/`roll` ported
from Part A's `score.py`) — a room-tone swell for the hook, a Part B bed with a sub impact on the B1
reveal, a shimmer on B3's eyes, a roll under B4, a hush at B5 (source: `evidence/assembly-BUILD.md:48-52`).
**Part A's own rendered score is reused unmodified**, not re-synthesized (source: same section,
"Part A's own score ... is reused unmodified"). All three stems are placed with `adelay` at their
timeline offsets and `amix`ed, then mastered with ffmpeg's `loudnorm` filter in **two passes**:

```bash
# pass 1: measure only
ffmpeg -i premix.wav -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null - 2> loudnorm-pass1.log
# parse input_i / input_tp / input_lra / input_thresh / target_offset out of the JSON, then:
ffmpeg -i premix.wav -af "loudnorm=I=-14:TP=-1:LRA=11:measured_I=...:measured_TP=...:measured_LRA=...:measured_thresh=...:offset=...:linear=true" \
  -ar 48000 -ac 2 mastered.wav
```

Target: I=−14 LUFS, TP=−1 dBFS, LRA=11 (source: `evidence/assembly-BUILD.md:55`; the exact
pass-1/pass-2 ffmpeg invocations are a private project script, excerpt above — the code block
reproduces the actual pattern used).
`linear=true` on pass 2 applies the exact measured gain rather than re-running the (slightly
nonlinear) dynamic algorithm a second time — use the measured values from pass 1, don't just run
`loudnorm` once and hope the one-pass dynamic version lands on target.

## Timeline math (so offsets are checkable, not just copied)

```
core  = (16.0 + 5.0 − 0.5) + 4.0 + 4.0 + 4.0 + 4.0 = 36.5 s   # Part A + B1, minus the 0.5s xfade overlap, + B2..B5
total = 2.5 (hook) + core − 0.5 (hook→core xfade) + 3.0 (end, hard cut) = 41.5 s
```
(source: `evidence/assembly-BUILD.md:70-77`). Every `-t` / `offset=` value passed to ffmpeg in the
assembly script should be derivable from a sum like this; if it isn't, the duration drifted from what
the shot list says it should be and something upstream changed without the script being updated.

## Verification

- **Read frames at every cut** — both hard cuts and the one crossfade — composited with their real
  captions, not a synthetic test pattern (source: private project document, excerpt above — the same
  per-shot layout log cited in "Keeping caption bands clear of the subject" above).
- **Duration**, measured directly, not computed: `ffprobe -show_entries format=duration -v quiet -of csv=p=0 final-film-en.mp4` → must match the shot list's stated total (source:
  `evidence/comparison-NUMBERS.md:87`, "measured directly ... → `41.500000`").
- Loudness was verified via `loudnorm`'s own two-pass measurement (`print_format=json` on pass 1,
  `print_format=summary` on pass 2), not the separate `ebur128` filter — **no source document in this
  project names `ebur128` specifically**; if your pipeline wants an independent post-hoc loudness
  check, `ffmpeg -i out.mp4 -af ebur128 -f null -` is the standard tool for that, but treat it as an
  addition, not something this project is shown to have used.

## Generic template

See `skill/templates/assemble_overlay_example.sh` — a minimal, syntax-checked (`bash -n`) skeleton of
the alpha-fade caption composite (with the `-loop 1` fix) and the two-pass `loudnorm` mastering step,
parameterized so it isn't specific to this project's file names. It is a template to copy from, not a
drop-in script — it does not know your shot list, font files, or caption copy.
