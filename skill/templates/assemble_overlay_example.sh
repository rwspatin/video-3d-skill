#!/bin/bash
# Generic skeleton: alpha-fade caption overlay (with the -loop 1 fix) + two-pass loudnorm mastering.
# Derived from a real project's final-film/build.sh (see skill/references/assembly.md). This is a
# TEMPLATE to copy sections from, not a drop-in script: it has no shot list, no font files, no real
# source clips. Every value that would be project-specific is a variable with an example default.
#
# Verify with: bash -n assemble_overlay_example.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# ---- inputs you would set per project --------------------------------------------------------
SRC_CLIP="${SRC_CLIP:-shot.mp4}"            # the video to caption, no audio required
CAPTION_PNG="${CAPTION_PNG:-caption.png}"   # transparent PNG, same resolution as SRC_CLIP
CLIP_DURATION="${CLIP_DURATION:-4.0}"       # seconds
FADE_DURATION="${FADE_DURATION:-0.4}"       # seconds, in and out
OUT_CLIP="${OUT_CLIP:-work/shot-cap.mp4}"
FPS="${FPS:-24}"

mkdir -p "$(dirname "$OUT_CLIP")"

# ---- step 1: composite the caption with an alpha fade (the -loop 1 fix) ---------------------
# Without "-loop 1" on the still-image input, ffmpeg decodes ONE frame of the PNG at its own
# pts=0 -- the very start of the alpha fade-in -- so the caption is fully transparent for the
# WHOLE clip, every frame, and ffmpeg still exits 0. Always verify by reading a real frame of the
# output, not by trusting the exit code.
fade_out_start="$(python3 -c "print(${CLIP_DURATION} - ${FADE_DURATION})")"

ffmpeg -y -v error -threads 4 \
  -i "$SRC_CLIP" \
  -loop 1 -i "$CAPTION_PNG" \
  -filter_complex "\
[1:v]format=rgba,fade=t=in:st=0:d=${FADE_DURATION}:alpha=1,fade=t=out:st=${fade_out_start}:d=${FADE_DURATION}:alpha=1[ov]; \
[0:v][ov]overlay=0:0:format=auto,format=yuv420p[v]" \
  -map "[v]" -t "$CLIP_DURATION" -threads 4 -c:v libx264 -crf 16 -pix_fmt yuv420p -r "$FPS" \
  "$OUT_CLIP"

echo "wrote $OUT_CLIP"

# ---- step 2: two-pass loudnorm mastering -----------------------------------------------------
# Target: I=-14 LUFS, TP=-1 dBFS, LRA=11 (a common streaming-safe target; adjust per brief).
# Pass 1 only measures; pass 2 applies the measured values with linear=true so the exact gain
# from pass 1 is used instead of re-running the (slightly nonlinear) dynamic algorithm again.
PREMIX_WAV="${PREMIX_WAV:-work/premix.wav}"
MASTERED_WAV="${MASTERED_WAV:-work/mastered.wav}"
LOUDNORM_I="${LOUDNORM_I:--14}"
LOUDNORM_TP="${LOUDNORM_TP:--1}"
LOUDNORM_LRA="${LOUDNORM_LRA:-11}"
PASS1_LOG="${PASS1_LOG:-work/loudnorm-pass1.log}"

mkdir -p "$(dirname "$PASS1_LOG")"

master_audio() {
  if [ ! -f "$PREMIX_WAV" ]; then
    echo "skip: $PREMIX_WAV not found (this is a template; supply a real premix)" >&2
    return 0
  fi

  ffmpeg -i "$PREMIX_WAV" \
    -af "loudnorm=I=${LOUDNORM_I}:TP=${LOUDNORM_TP}:LRA=${LOUDNORM_LRA}:print_format=json" \
    -f null - > "$PASS1_LOG" 2>&1 || true

  # extract the measured_* values from pass 1's JSON block and write them as shell vars
  python3 -c "
import json
s = open('$PASS1_LOG').read()
m = s[s.index('{'): s.rindex('}') + 1]
j = json.loads(m)
open('work/loudnorm-meas.sh', 'w').write(
    f\"I='{j['input_i']}'; TP='{j['input_tp']}'; LRA='{j['input_lra']}'; THRESH='{j['input_thresh']}'; OFFSET='{j['target_offset']}'\n\"
)
"
  # shellcheck disable=SC1091
  source work/loudnorm-meas.sh

  ffmpeg -y -v error -i "$PREMIX_WAV" \
    -af "loudnorm=I=${LOUDNORM_I}:TP=${LOUDNORM_TP}:LRA=${LOUDNORM_LRA}:measured_I=$I:measured_TP=$TP:measured_LRA=$LRA:measured_thresh=$THRESH:offset=$OFFSET:linear=true:print_format=summary" \
    -ar 48000 -ac 2 "$MASTERED_WAV"

  echo "wrote $MASTERED_WAV"
}

master_audio

# ---- verification reminders (not automated here) ----------------------------------------------
# - Read an actual decoded frame of $OUT_CLIP mid-fade; confirm the caption is visible, not just
#   that ffmpeg exited 0.
# - ffprobe -show_entries format=duration -v quiet -of csv=p=0 "$OUT_CLIP" should match
#   $CLIP_DURATION.
# - ffmpeg -i "$MASTERED_WAV" -af ebur128 -f null - is a reasonable independent loudness spot check
#   if you want one beyond loudnorm's own pass-1 measurement.
