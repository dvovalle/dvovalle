#!/bin/bash

xfreerdp /v:172.20.80.92 /u:"$USER" /p:"$PASSWORD" /d:kalunga.com.br /w:1920 /h:1080 /t:MADESENV01 /f +fonts /floatbar /tls-seclevel:0 /timeout:50000


exit 0
