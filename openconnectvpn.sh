#!/bin/bash
BASE32_TOKEN=FWXUXRNPFDG5XLCUSTJ5WTVNMTPM4X3PGCT4ZA6P4VQPPKETPSZGZJMQLWTEJUQEYH3QPZVGF7GE7IOOEJZVUPSWH6S4JTTRBUAIKA7SWMMNIHEMTER5I73O2DKLW6X7W5XEHO42W4YDGWMQOUH4722KE7V7EMIZZRQAUVHUGRDTN6XBXVKCN7Y6ZLWWFEPYGBHSKF7JOFW4W
HOSTVPN=https://vpn.kalunga.com.br
SERVERCERT=pin-sha256:VNdgrGA/40zSZ94GqqDna2d7e7uZ+b1VWID9RPby1Eg=
TOKEN=`oathtool --base32 --totp $BASE32_TOKEN`
# echo $TOKEN | openconnect --passwd-on-stdin $HOSTVPN --authgroup Kalunga -m 1290 --user=daniloka --servercert $SERVERCERT --token-mode=totp --token-secret=$BASE32_TOKEN  --script '/home/danilo/vpnkascript.conf'
echo $TOKEN | openconnect --passwd-on-stdin $HOSTVPN --authgroup Kalunga -m 1290 --user=daniloka --token-mode=totp --token-secret=$BASE32_TOKEN  --script '/home/danilo/vpnkascript.conf'

