# Documentacao
# https://wiki.archlinux.org/title/NetworkManager
# https://man.archlinux.org/man/nmcli-examples.7.en

# Lista as redes wifi
# nmcli device wifi list

# nmcli connection show

# Connect
# nmcli device wifi connect 70:0B:01:3C:5E:27

# Connect IronVirus5Ghz
#export WIFIPASSWORD='xeonserver2004!Roma10'
#export SSID='IronVirus5Ghz'
SSID="IronVirus2"
WIFIPASSWORD='xeonserver2004!Roma10'
nmcli device wifi connect "$SSID" password "$WIFIPASSWORD"

# disconnect
# nmcli device disconnect ifname wlp3s0


# nmcli -p -f general,wifi-properties device show wlp3s0
# nmcli general permissions
