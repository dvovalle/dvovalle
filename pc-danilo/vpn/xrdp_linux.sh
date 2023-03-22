#!/bin/bash

# read -p "Informe o numero da máquina: " MAQUINA
# https://sysadminmosaic.ru/_media/freerdp/freerdp-user-manual.pdf

xfreerdp /v:172.20.80.84 /u:"danilo" /p:"rmk102030" /kbd:0x00010416 /d:kalunga.com.br /w:1920 /h:1080 /t:MADESENVNT23 /f +fonts +clipboard -themes /cert-ignore /floatbar


exit 0
