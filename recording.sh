mkdir -p ./00_RECORDING/
ffmpeg -f v4l2 -video_size 1920x1080 -framerate 30 -i /dev/video0 \
    -f alsa -ac 2 -i hw:1 \
    -c:v libx265 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -af aresample=async=1 \
    -t 00:03:00 ./00_RECORDING/H265-recorded.mp4 -y
