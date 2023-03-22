#!/bin/bash

# read -p "Informe o numero da máquina: " MAQUINA
# https://sysadminmosaic.ru/_media/freerdp/freerdp-user-manual.pdf

xfreerdp /v:172.20.80.85 /u:"daniloka" /p:"kalunga04" /kbd:0x00010416 /d:kalunga.com.br /w:1920 /h:1080 /t:MADESENVNT29 /f +fonts +clipboard -themes /cert-ignore /floatbar


exit 0
