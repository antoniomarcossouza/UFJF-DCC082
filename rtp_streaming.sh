# ffplay -protocol_whitelist rtp,udp -i "udp://localhost:5004"
ffmpeg -re -i ./04_TS/ts_container.ts -c:v libx264 -c:a aac -f rtp_mpegts rtp://localhost:5004