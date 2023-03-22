#!/bin/bash
echo 'Iniciando'

URL=https://vimeo.com/25217349
TEMPNOME='/home/danilo/Music/mp3/NotoriousBig-TupacBack.mp3'
NOME=$(echo $TEMPNOME | tr -d ' ')
USERAGENT='Mozilla/5.0 (X11; Linux x86_64; rv:87.0) Gecko/20100101 Firefox/87.0'


youtube-dl -x -f bestaudio[ext=m4a] --extract-audio --audio-format mp3 --add-metadata https://www.youtube.com/watch?v=5BdcDAhDhIs


youtube-dl -x -f bestaudio[ext=m4a] --extract-audio --add-metadata https://www.youtube.com/watch?v=0G383538qzQ


