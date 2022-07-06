#!/bin/bash

# https://www.systutorials.com/docs/linux/man/1-rdesktop/

RESOLUCAO=1920x1080
USER="danilo ka"
DOMAIN=kalunga.com.br
PASSWD="kalunga07"
MACHINE=172.16.201.23
LAYOUTKEY=br

rdesktop -u $USER -d $DOMAIN -p $PASSWD -n $HOSTNAME -k $LAYOUTKEY -g $RESOLUCAO -f -t -m -D -P -z -x l -r sound:off $MACHINE

