#!/bin/bash

source /root/venv/bin/activate

VPN_AUTHGROUP="INTRANET"
VPN_HOSTVPN=https://vpn.kalunga.com.br
VPN_BASE32_TOKEN=FWXUXRNPFDG5XLCUSTJ5WTVNMTPM4X3PGCT4ZA6P4VQPPKETPSZGZJMQLWTEJUQEYH3QPZVGF7GE7IOOEJZVUPSWH6S4JTTRBUAIKA7SWMMNIHEMTER5I73O2DKLW6X7W5XEHO42W4YDGWMQOUH4722KE7V7EMIZZRQAUVHUGRDTN6XBXVKCN7Y6ZLWWFEPYGBHSKF7JOFW4W
VPN_TOKEN=`oathtool --base32 --totp $VPN_BASE32_TOKEN`
VPN_USER="daniloka"
VPN_PASSWORD="kalunga14"
VPN_SEQUENCE="\n${VPN_USER}\n${VPN_PASSWORD}\n${VPN_TOKEN}"

FILE_RC='/home/danilo/.bashrc'
FILE_RC_ROOT='/root/.bashrc'
FILE_CONFIGVPN='/home/danilo/GitHub/dvovalle/vpn/configvpn.conf'


sed -i "s/user=.*/user=$VPN_USER/" $FILE_CONFIGVPN
sed -i "s/key-password=.*/key-password=$VPN_PASSWORD/" $FILE_CONFIGVPN
sed -i "s/authgroup=.*/authgroup=$VPN_AUTHGROUP/" $FILE_CONFIGVPN
sed -i "s/form-entry=unicorn_form:username=.*/form-entry=unicorn_form:username=$VPN_USER/" $FILE_CONFIGVPN
sed -i "s/form-entry=unicorn_form:password=.*/form-entry=unicorn_form:password=$VPN_PASSWORD/" $FILE_CONFIGVPN
sed -i "s/form-entry=unicorn_form:group_list=.*/form-entry=unicorn_form:group_list=$VPN_AUTHGROUP/" $FILE_CONFIGVPN
sed -i "s/token-secret=.*/token-secret='$VPN_BASE32_TOKEN'/" $FILE_CONFIGVPN

echo -e $VPN_SEQUENCE | openconnect $VPN_HOSTVPN --config=$FILE_CONFIGVPN

exit 0
