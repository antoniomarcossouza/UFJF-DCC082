ffmpeg -f v4l2 -video_size 1920x1080 -framerate 30 -i /dev/video0 \
    -f alsa -ac 2 -i hw:1 \
    -c:v libx265 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -af aresample=async=1 \
    -t 00:01:00 00_H265-recorded.mp4 -y

ffmpeg -i 00_H265-recorded.mp4 \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    01_H264-transcoded.mp4 -y

ffmpeg -i 00_H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1920:1080" -an 02_video1080p.mp4
ffmpeg -i 00_H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1280:720,interlace" -an 02_video720i.mp4
ffmpeg -i 00_H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=854:480" -an 02_video480p.mp4
ffmpeg -i 00_H265-recorded.mp4 -c:a aac -b:a 64k -ac 1 02_audio_mono.aac
ffmpeg -i 00_H265-recorded.mp4 -c:a aac -b:a 128k -ac 2 02_audio_stereo.aac
