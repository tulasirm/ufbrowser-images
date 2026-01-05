#!/bin/bash

# Default to :99 if DISPLAY not set
DISPLAY=${DISPLAY:-:99}
RESOLUTION=${RESOLUTION:-1920x1080}
VIDEO_PATH=${VIDEO_PATH:-/tmp/recording.mp4}
FRAMERATE=${FRAMERATE:-30}

echo "Starting Recording of $DISPLAY ($RESOLUTION) to $VIDEO_PATH..."

# Ensure directory exists
mkdir -p $(dirname "$VIDEO_PATH")

# Start FFmpeg
# -y : Overwrite output
# -f x11grab : Grab X11 display
# -s $RESOLUTION : Size
# -i $DISPLAY : Input display
# -r $FRAMERATE : Framerate
ffmpeg -y \
    -f x11grab \
    -s "$RESOLUTION" \
    -framerate "$FRAMERATE" \
    -i "$DISPLAY" \
    -c:v libx264 -preset ultrafast -tune zerolatency -pix_fmt yuv420p \
    "$VIDEO_PATH"
