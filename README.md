# Trabalho prático - DCC082

## 1. Captura e Codificação de Áudio e Vídeo em Tempo Real
O comando abaixo serve para gravação do vídeo da webcam em 1080p e áudio estéreo:
```
ffmpeg -f v4l2 -video_size 1920x1080 -framerate 30 -i /dev/video0 \
    -f alsa -ac 2 -i hw:1 \
    -c:v libx265 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -af aresample=async=1 \
    -t 00:03:00 ./00_RECORDING/H265-recorded.mp4 -y
```

## 2. Transcodificação de Vídeo
O comando abaixo transcodifica o vídeo gravado anteriormente para H.264:
```
mkdir -p ./01_H264
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    ./01_H264/H264-transcoded.mp4 -y
```

## 3. Multiplexação de Conteúdo em DASH com Alternativas de Qualidade de Vídeo e Áudio
Primeiro, precisamos criar os arquivos de vídeo e áudio que serão as alternativas para o contêiner DASH:
```
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1920:1080" -an ./02_STAGING/video1080p.mp4 -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=1280:720,interlace" -an ./02_STAGING/video720i.mp4 -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:v libx265 -crf 23 -vf "scale=854:480" -an ./02_STAGING/video480p.mp4 -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:a aac -b:a 128k -ac 1 ./02_STAGING/audio_mono.aac -y
ffmpeg -i ./00_RECORDING/H265-recorded.mp4 -c:a aac -b:a 128k -ac 2 ./02_STAGING/audio_stereo.aac -y
```

Então, todos os arquivos são unidos com o comando abaixo, que gera o manifesto:
```
ffmpeg -i ./02/video1080p.mp4 -i ./02/video720i.mp4 -i ./02/video480p.mp4 \
    -i ./02/audio_mono.aac -i ./02/audio_stereo.aac \
    -map 0:v -map 1:v -map 2:v -map 3:a -map 4:a \
    -c:v libx265 -c:a aac \
    -seg_duration 4 -use_timeline 1 -use_template 1 \
    -f dash ./03_DASH/dash_container.mpd -y
```

### 4. Multiplexação do Conteúdo em MPEG-2 TS
O comando abaixo multiplexa o arquivo gerado no passo 2 para o formato Transport Stream:
```
ffmpeg -i ./01_H264/H264-transcoded.mp4 \
    -c:v libx264 -c:a aac \
    -f mpegts ./04_TS/ts_container.ts -y
```

## 5. Streaming do Conteúdo e Teste
Para fazer o stream do conteúdo do passo 3:
```
python3 -m http.server --directory ./03/ 8080
```
Para visualizar com ffplay:
```
ffplay http://localhost:8080/dash_container.mpd
```
Para fazer o stream do conteúdo do passo 4:
```
ffmpeg -re -i ./04_TS/ts_container.ts -c:v libx264 -c:a aac -f rtp_mpegts rtp://localhost:5004
```
Para visualizar com ffplay:
```
ffplay -protocol_whitelist rtp,udp -i "udp://localhost:5004"
```