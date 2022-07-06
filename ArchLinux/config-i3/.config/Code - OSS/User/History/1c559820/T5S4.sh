#!/bin/bash

# https://www.systutorials.com/docs/linux/man/1-rdesktop/
# rdesktop -u "danilo ka" -d kalunga.com.br -p "kalunga07" -k br-abnt2 -g 1920x1080 -f -t -m -D -P -z -x l -r sound:off 172.16.201.23


# https://raw.githubusercontent.com/awakecoding/FreeRDP-Manuals/master/User/FreeRDP-User-Manual.pdf

xfreerdp /v:172.16.201.23 /u:"danilo ka" /p:"kalunga07" /d:kalunga.com.br /w:1920 /h:1080 /t:MADESENVNT29 +toggle
