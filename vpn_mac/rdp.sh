#!/bin/bash

# read -p "Informe o numero da máquina: " MAQUINA

xfreerdp /v:172.20.80.85 /u:"daniloka" /p:"kalunga15" /d:kalunga.com.br /w:1920 /h:1080 /t:MADESENVNT29 /f +fonts /floatbar

exit 0
