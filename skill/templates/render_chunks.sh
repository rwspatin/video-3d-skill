#!/bin/bash
# Generic resumable, chunked Blender headless render wrapper with a stalled-chunk watchdog.
#
# Derived from a real project's tools/render_final.sh (chunking + resume + "one Blender at a time")
# and tools/render_final_v2.sh (adds the watchdog). See skill/references/blender-headless.md for the
# sourced numbers this pattern is based on.
#
# Do NOT run this with Blender as part of writing/reviewing this skill -- it is a template. Verify it
# only with a syntax checker:
#   bash -n render_chunks.sh
#   zsh -n render_chunks.sh
#
# Required env vars:
#   BLENDER       path to the Blender binary
#                 e.g. /Applications/Blender.app/Contents/MacOS/Blender
#   SCRIPT        the Python render driver script, run as: $BLENDER -b --factory-startup -P "$SCRIPT" -- <args>
#   FRAMES_TOTAL  total frame count to render (frames 1..FRAMES_TOTAL)
#   OUT_DIR       output directory; frames go to $OUT_DIR/raw/f_%04d.png, log to $OUT_DIR/render.log
#
# Optional env vars:
#   CHUNK         frames per chunk, each in a fresh Blender process (default 8)
#   STALL_SECS    seconds with no new frame file before the watchdog kills and retries a chunk (default 480)
#   MAX_TRIES     max watchdog retries per chunk before giving up on it (default 3)
#   EXTRA_ARGS    extra arguments appended to the Blender invocation, e.g. "--samples 16 --pct 75"
#   FRAME_ARG     the CLI flag your script expects for a frame range (default "--frames")
#   OUT_ARG       the CLI flag your script expects for the output path prefix (default "--out")
#
# What this script assumes about SCRIPT (adjust FRAME_ARG/OUT_ARG, or edit the invocation, otherwise):
#   $BLENDER -b --factory-startup -P "$SCRIPT" -- $EXTRA_ARGS $FRAME_ARG "$a-$b" $OUT_ARG "$OUT_DIR/raw/f_"
#   and that it writes one PNG per rendered frame as "$OUT_DIR/raw/f_<NNNN>.png".

set -euo pipefail

: "${BLENDER:?set BLENDER to the Blender binary path}"
: "${SCRIPT:?set SCRIPT to the Python render driver script}"
: "${FRAMES_TOTAL:?set FRAMES_TOTAL to the total frame count}"
: "${OUT_DIR:?set OUT_DIR to the output directory}"

CHUNK="${CHUNK:-8}"
STALL_SECS="${STALL_SECS:-480}"
MAX_TRIES="${MAX_TRIES:-3}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
FRAME_ARG="${FRAME_ARG:---frames}"
OUT_ARG="${OUT_ARG:---out}"

mkdir -p "$OUT_DIR/raw"

# Rule 1: only one Blender process at a time. Refuse to start if another is already running -- this
# is what makes it safe to launch this script with `&`/nohup without racing a render you forgot about.
if pgrep -f "Blender -b" >/dev/null 2>&1; then
  echo "another Blender is running; abort" | tee -a "$OUT_DIR/render.log"
  exit 1
fi

# Everything from here on is appended to the log, so the script is safe to detach with nohup.
exec >> "$OUT_DIR/render.log" 2>&1

echo "== start $(date) == frames=1-$FRAMES_TOTAL chunk=$CHUNK stall=${STALL_SECS}s"

frame_file() {
  # $1 = frame number -> path of that frame's expected output PNG
  printf "%s/raw/f_%04d.png" "$OUT_DIR" "$1"
}

a=1
while [ "$a" -le "$FRAMES_TOTAL" ]; do
  b=$((a + CHUNK - 1))
  if [ "$b" -gt "$FRAMES_TOTAL" ]; then b="$FRAMES_TOTAL"; fi

  last_file="$(frame_file "$b")"

  # Resume: a chunk whose LAST frame already exists is considered done. Skip it.
  if [ -f "$last_file" ]; then
    echo "== chunk $a-$b already done, skipping"
    a=$((b + 1))
    continue
  fi

  tries=0
  while [ ! -f "$last_file" ] && [ "$tries" -lt "$MAX_TRIES" ]; do
    tries=$((tries + 1))
    echo "== chunk $a-$b try $tries/$MAX_TRIES $(date)"

    # shellcheck disable=SC2086
    "$BLENDER" -b --factory-startup -P "$SCRIPT" -- $EXTRA_ARGS "$FRAME_ARG" "$a-$b" "$OUT_ARG" "$OUT_DIR/raw/f_" \
      2>&1 | grep --line-buffered -E "^\[frame\]|Traceback|Error" &
    bg_pid=$!

    sleep 2
    blender_pid="$(pgrep -f "Blender -b" | head -1 || true)"
    last_progress="$(date +%s)"
    prev_count="$(ls "$OUT_DIR/raw" 2>/dev/null | wc -l | tr -d ' ')"

    # Watchdog: as long as the Blender process is alive, poll for new frame files. If STALL_SECS
    # pass with no new file, kill it (SIGTERM then SIGKILL) and let the outer while-loop retry.
    while [ -n "$blender_pid" ] && kill -0 "$blender_pid" 2>/dev/null; do
      sleep 20
      cur_count="$(ls "$OUT_DIR/raw" 2>/dev/null | wc -l | tr -d ' ')"
      if [ "$cur_count" != "$prev_count" ]; then
        prev_count="$cur_count"
        last_progress="$(date +%s)"
      fi
      now="$(date +%s)"
      if [ $((now - last_progress)) -gt "$STALL_SECS" ]; then
        echo "== WATCHDOG: no new frame for ${STALL_SECS}s, killing chunk $a-$b (try $tries) $(date)"
        kill "$blender_pid" 2>/dev/null || true
        sleep 5
        kill -9 "$blender_pid" 2>/dev/null || true
        break
      fi
    done

    wait "$bg_pid" 2>/dev/null || true
  done

  if [ ! -f "$last_file" ]; then
    echo "== chunk $a-$b FAILED after $MAX_TRIES tries, giving up $(date)"
    exit 1
  fi

  echo "== chunk $a-$b done $(date)"
  a=$((b + 1))
done

echo "== DONE $(date) $(ls "$OUT_DIR/raw" | wc -l) png"
