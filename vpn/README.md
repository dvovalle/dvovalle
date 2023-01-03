# openconnect: VPN COnnect
pacman -S openconnect

## oath
pacman -S oath-toolkit

## VPN Slice
git clone https://aur.archlinux.org/vpn-slice-git.git




#!/bin/bash
BASE32_TOKEN=***COLAAQUI***
TOKEN=`oathtool --base32 --totp $BASE32_TOKEN`
echo 'TOKEN: ' $TOKEN

openconnect --config='/home/danilo/vpn/configvpn.conf'

# echo -e "$PASSWORD\n$TOKEN" | openconnect --config='/home/danilo/vpn/configvpn.conf'

# exit 0



sudo apt-get install openconnect
sudo apt-get install oathtool

openconnect - é o que faz a conexão
oathtool    - é o Google Authenticator
vpn-slice   - Vai fazer o TUN para vc usar VPN e internet normal