# BUILD — "The Wheels of Ezekiel"

## One command

```bash
cd final-film   # project root, private repo
./build.sh
```

Produces `final-film-en.mp4` and `final-film-pt.mp4` (1080×1350, 24 fps, ~41.5 s, H.264 yuv420p
+faststart, AAC 192k 48 kHz stereo, −14 LUFS). Needs `ffmpeg`/`ffprobe`, `python3`, `node`, and the
Chromium cached by the teardown skill at `~/Library/Caches/ms-playwright/chromium-1248/` (the script
finds it itself). Does not touch any source folder — it only reads from
`ezekiel-part-a-v2/`, `ezekiel-ophanim-v7/out/{final,final_v2}/`, and
`ezekiel-encounter/text/`, and writes under `final-film/`.

## B-shot source selection (for the B4/B5 re-shoot)

`build.sh` has a `src_for()` helper: for each of B1–B5 it prefers
`ezekiel-ophanim-v7/out/final_v2/<id>.mp4` over `.../out/final/<id>.mp4` **if the `final_v2` file
exists**. The script prints which source it picked for each shot at the top of its output ("== sources
==").

**Status: already used.** B4 and B5 were re-shot (man was cut off at the frame edge in B4, read as an
unclear grey lump in B5) and now exist at `out/final_v2/B4.mp4` / `B5.mp4`; `build.sh` picked them up
automatically on the last run — no script changes were needed, confirming the source-preference
mechanism works as intended. B1–B3 still come from `out/final/` (no `final_v2` exists for those).

## Pipeline (what `build.sh` does, in order)

1. **Captions + title cards** (`work/gen-captions.mjs`, `work/gen-cards.mjs`): renders transparent
   1080×1350 PNGs for the five B-shot captions and opaque PNGs for the hook/end cards, via Playwright
   + the cached Chromium, using the same fonts as Part A's overlay (Cormorant Garamond italic 500 /
   normal 600, JetBrains Mono 600 — base64-embedded, read once into `work/fonts_b64.json`) and the same
   palette (`#f6eedf` ivory, `#ffd27a` gold accent, dark gradient scrims). Shot copy/layout lives in
   `work/shots.json`. One Chromium instance, shots rendered sequentially (per the "one Chromium at a
   time" constraint while the Blender render was running).
2. **Hook/end cards → video**: each still gets a slow Ken Burns zoom (`zoompan`) and is encoded to a
   fixed-duration clip (hook 2.5 s, end 3.0 s with a 1.0 s fade-to-black baked in at the very end).
3. **Composite captions onto B1–B5**: `overlay` with the caption PNG, `fade`d on its **alpha** channel
   (0.4 s in/out) — not `drawtext`, so the real Cormorant/JetBrains Mono glyphs are used. The caption
   PNG is given `-loop 1` (critical: without it ffmpeg decodes a single frame of a still image at its
   own pts=0, which is the very start of the alpha fade-in, so the caption renders fully transparent
   for the entire clip — this bit the first build and was caught by reading an actual frame from the
   composited output, not just trusting "ffmpeg exited 0").
4. **Core chain**: Part A (silent) **crossfades** 0.5 s into B1 (xfade), then B1→B2→B3→B4→B5 are
   **hard cuts** (ffmpeg `concat`), not dissolves. See "why hard cuts" below.
5. **Audio**: `work/gen_audio.py` renders two new stems with the same synthesis kit as Part A's score
   (`~/.claude/skills/teardown/sfx/`: `pad`, `chime`, `bandnoise`, plus `drone`/`shimmer`/`roll`
   ported from Part A's `score.py`) — a faint room-tone swell for the hook card, and a lower, warmer
   Part B bed (continuing drone, a sub impact on the B1 reveal, a shimmer on B3's eyes, a roll under
   B4, a hush at B5, a last soft bell into the end card). Part A's own score
   (`ezekiel-part-a-v2/out/part-a-v2-score.wav`) is reused unmodified. All three stems are placed by
   `adelay` (hook at 0 ms, Part A score at 2000 ms, Part B bed at 16500 ms) and `amix`ed, then mastered
   with **two-pass `loudnorm`** (I=−14 LUFS, TP=−1 dBFS, LRA=11) — pass 1 measures, pass 2 applies the
   measured values with `linear=true`.
6. **Final mux**: hook crossfades 0.5 s into the core chain, hard-cuts into the end card, muxed with
   the mastered audio, H.264 crf 19 yuv420p + faststart, AAC 192k.

## Why hard cuts between B-shots (not the 0.25–0.4 s dissolve the brief allowed)

Tried a 0.3 s `xfade` between every B-shot first. The problem: each B-shot has its **own** caption
block (different title, different quote), so during the 0.3 s dissolve the outgoing shot's caption
and the incoming shot's caption are both partially opaque and literally overlap — two paragraphs of
text double-exposed on top of each other, unreadable. A hard cut keeps each caption crisp. Part A → B1
still crossfades because Part A's own caption has already faded out by the time the dissolve starts
(checked at the actual crossfade frame — see `frames/qa/f05_t17.75.png` from the build session), so
there's no second caption to collide with.

## Timeline math (so the offsets in `build.sh` are checkable)

Hook 2.5 s, Part A 16.0 s (xfade 0.5 s into B1), B1 5.0 s, B2–B5 4.0 s each (hard cuts), end 3.0 s:

```
core  = (16.0 + 5.0 − 0.5) + 4.0 + 4.0 + 4.0 + 4.0        = 36.5 s
total = 2.5 + core − 0.5 (hook→core xfade) + 3.0 (end, hard cut) = 41.5 s
```

## Regenerating only part of it

- `node work/gen-captions.mjs B3` — re-render just the B3 caption PNG (edit `work/shots.json` first).
- `node work/gen-cards.mjs` — re-render all 4+4 hook/end cards (v2 and v3, see below).
- `python3 -I work/gen_audio.py` — re-render `work/audio-hook.wav` and `work/audio-partb.wav`.

None of these touch `final-film-*.mp4` by themselves; re-run `./build.sh` (or the relevant later
steps in it by hand) to fold changes into the final mux.

## Variants: `HOOK_VARIANT=<v3|v4|...>` (text-only hook/end changes)

```bash
./build.sh                     # first, once (or whenever the v2 pipeline needs a real rebuild)
HOOK_VARIANT=v3 ./build.sh     # then, any time — produces the v3 files, never touches v2
HOOK_VARIANT=v4 ./build.sh     # or v4 — never touches v2 or v3
```

The `HOOK_VARIANT` branch in `build.sh` is generic over the suffix (not hardcoded to "v3"): it reads
`work/hook-<lang>-<variant>.png` / `work/end-<lang>-<variant>.png` (rendered by `gen-cards.mjs`'s
`CARDS` list) and writes `final-film-<lang>-<variant>.mp4`. Adding a new variant = add entries to
`CARDS` in `work/gen-cards.mjs`, then run `HOOK_VARIANT=<name> ./build.sh` — no other script edits.

Produces `final-film-en-v3.mp4` and `final-film-pt-v3.mp4` — **42.0 s** (v2 is 41.5 s), same
resolution/fps/codecs/loudness as v2. v3 changes **only** the hook card and adds one line to the end
card; no Blender or Part A re-render, same B1–B5 captions, same audio mix.

- **Hook (v3):** EN "Ezekiel never calls these wheels angels." / "Here is what the text actually
  says." · PT "Ezequiel nunca chama essas rodas de anjos." / "Veja o que o texto realmente diz."
  Replaces v2's "The Bible never describes angels the way we draw them." — that framing was
  inaccurate for a Catholic audience: Ezekiel 1 never calls the wheels (or the four living creatures)
  "angels" at all (Ez 10:20 names the creatures cherubim), and other biblical angels — Raphael in
  Tobit, for one — **are** described as ordinary young men. v3's hook makes a narrower, defensible
  claim: Ezekiel's own text doesn't use the word "angel" for what it describes.
- **End card (v3):** adds one small mono line below "BUILT WITH THREE.JS + BLENDER (CYCLES)": EN "A
  visual study made with AI. Not a substitute for an artist." · PT "Estudo visual feito com IA. Não
  substitui o trabalho de um artista." The end card is held 3.5 s instead of 3.0 s so the extra line
  can be read (fade-to-black still runs over the last 1.0 s, now starting at st=2.5 instead of 2.0).
- **How it's wired (`build.sh`):** `HOOK_VARIANT=<name>` branches at the very top of the script,
  before the "== sources ==" step, and takes a **separate, lightweight path**: it generates that
  variant's card PNGs (`gen-cards.mjs` always renders v2 + every variant's copy — see `CARDS` in that
  file — so this never overwrites another variant's PNGs), encodes just the two new hook/end clips,
  and muxes them with the **already-built** `work/core.mp4` (Part A + captioned B1–B5) and
  `work/mastered.wav` (the final audio mix) from a prior plain `./build.sh` run — then exits, skipping
  steps 1–6 entirely. This is what guarantees `final-film-en.mp4` / `final-film-pt.mp4` (and every
  other variant) are never re-encoded by a different variant's run: verified each time by hashing all
  prior files before and after (`shasum -a 256`) and confirming they're byte-identical. If
  `work/core.mp4` or `work/mastered.wav` don't exist yet, the variant path exits with an error telling
  you to run `./build.sh` (no flag) first.

## v4 variant

Same mechanism as v3 (`HOOK_VARIANT=v4`), also 42.0 s (end card held 3.5 s). The user didn't want a
theological-debate framing at all, so v4's hook is neutral — it just names the chapter and what's on
screen, no claim about what Ezekiel does or doesn't call the wheels:

- **Hook (v4):** EN "Wheels within wheels, full of eyes." / "Ezekiel 1, in images." · PT "Rodas
  dentro de rodas, cheias de olhos." / "Ezequiel 1, em imagens."
- **End card (v4):** same title, "EZEKIEL 1 · 2 · DOUAY-RHEIMS" line, and v3's AI-disclosure line as
  v3. The credit line is now per-language: EN keeps "BUILT WITH THREE.JS + BLENDER (CYCLES)"; PT is
  translated to "FEITO COM THREE.JS + BLENDER (CYCLES)" (v2/v3 PT end cards left that line in English
  — v4 is the first to translate it).
