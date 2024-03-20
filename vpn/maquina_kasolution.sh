#!/bin/bash

read -p "Informe o IP da máquina: " MAQUINA
read -p "Informe o login: " USER
read -p "Informe a senha: " SENHA

xfreerdp /v:$MAQUINA /u:"$USER" /p:"$SENHA" /d:kalunga.com.br /w:1920 /h:1080 /t:MAQUINAWINDOWS /f +fonts /floatbar


exit 0
