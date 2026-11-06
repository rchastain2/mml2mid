#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") MML_FILE [SOUNDFONT]" >&2
  exit 1
fi

DIR=$(dirname "$(readlink -f "$0")")
MML2MID="$DIR/mml2mid"
SOUNDFONT=${2:-${SOUNDFONT:-$HOME/Documents/audio/pasfluidsynth/fonts/FluidR3_GM2-2.SF2}}

if [ ! -x "$MML2MID" ]; then
  echo "Error: $MML2MID not found, run make first" >&2
  exit 1
fi
if [ ! -f "$1" ]; then
  echo "Error: file not found: $1" >&2
  exit 1
fi
if [ ! -f "$SOUNDFONT" ]; then
  echo "Error: soundfont not found: $SOUNDFONT" >&2
  exit 1
fi

MID=$(mktemp --suffix=.mid) || exit 1
trap 'command rm -f "$MID"' EXIT

"$MML2MID" "$1" "$MID" && fluidsynth -ni "$SOUNDFONT" "$MID"
