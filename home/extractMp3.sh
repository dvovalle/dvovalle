#!/bin/bash
echo 'Iniciando'
# https://github.com/yt-dlp/yt-dlp

# yt-dlp --extract-audio --audio-format mp3 $1
yt-dlp -f 'ba' -x --audio-format mp3 $1  -o '/home/danilo/Music/download/%(title)s.%(ext)s'
