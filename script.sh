ffmpeg -f v4l2 -video_size 1920x1080 -framerate 30 -i /dev/video0 \
    -f alsa -ac 2 -i hw:1 \
    -c:v libx265 -c:a aac \
    -af aresample=async=1 \
    -t 00:00:10 output.mp4 -y