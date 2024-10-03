mkdir -p ./00
ffmpeg -f v4l2 -video_size 1920x1080 -framerate 30 -i /dev/video0 \
    -f alsa -ac 2 -i hw:1 \
    -c:v libx265 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -af aresample=async=1 \
    -t 00:01:00 ./00/H265-recorded.mp4 -y

mkdir -p ./01
ffmpeg -i ./00/H265-recorded.mp4 \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    ./01/H264-transcoded.mp4 -y

mkdir -p ./02
ffmpeg -i ./00/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1920:1080" -an ./02/video1080p.mp4 -y
ffmpeg -i ./00/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1280:720,interlace" -an ./02/video720i.mp4 -y
ffmpeg -i ./00/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=854:480" -an ./02/video480p.mp4 -y
ffmpeg -i ./00/H265-recorded.mp4 -c:a aac -b:a 64k -ac 1 ./02/audio_mono.aac -y
ffmpeg -i ./00/H265-recorded.mp4 -c:a aac -b:a 128k -ac 2 ./02/audio_stereo.aac -y

mkdir -p ./03
ffmpeg -i ./02/video1080p.mp4 -i ./02/video720i.mp4 -i ./02/video480p.mp4 \
    -i ./02/audio_mono.aac -i ./02/audio_stereo.aac \
    -map 0:v -map 1:v -map 2:v -map 3:a -map 4:a \
    -c:v libx265 -c:a aac \
    -seg_duration 4 -use_timeline 1 -use_template 1 \
    -f dash ./03/dash_container.mpd -y

mkdir -p ./04
ffmpeg -i ./01/H264-transcoded.mp4 \
    -c:v libx264 -c:a aac \
    -seg_duration 4 -use_timeline 1 -use_template 1 \
    -f mpegts ./04/ts_container.ts -y
