mkdir -p ./00_RECORDING/
ffmpeg -f v4l2 -video_size 1920x1080 -framerate 30 -i /dev/video0 \
    -f alsa -ac 2 -i hw:1 \
    -c:v libx265 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -af aresample=async=1 \
    -t 00:01:00 ./00_RECORDING/H265-recorded.mp4 -y

mkdir -p ./01_H264
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    ./01_H264/H264-transcoded.mp4 -y

mkdir -p ./02_STAGING
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1920:1080" -an ./02_STAGING/video1080p.mp4 -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1280:720,interlace" -an ./02_STAGING/video720i.mp4 -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=854:480" -an ./02_STAGING/video480p.mp4 -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:a aac -b:a 64k -ac 1 ./02_STAGING/audio_mono.aac -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:a aac -b:a 128k -ac 2 ./02_STAGING/audio_stereo.aac -y

mkdir -p ./03_DASH
ffmpeg -i ./02/video1080p.mp4 -i ./02/video720i.mp4 -i ./02/video480p.mp4 \
    -i ./02/audio_mono.aac -i ./02/audio_stereo.aac \
    -map 0:v -map 1:v -map 2:v -map 3:a -map 4:a \
    -c:v libx265 -c:a aac \
    -seg_duration 4 -use_timeline 1 -use_template 1 \
    -f dash ./03_DASH/dash_container.mpd -y

mkdir -p ./04_TS
ffmpeg -i ./01_H264/H264-transcoded.mp4 \
    -c:v libx264 -c:a aac \
    -f mpegts ./04_TS/ts_container.ts -y
