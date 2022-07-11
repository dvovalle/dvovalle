# Documentacao
# https://wiki.archlinux.org/title/NetworkManager

# Lista as redes wifi
# nmcli device wifi list

# nmcli connection show

# Connect
# nmcli device wifi connect 70:0B:01:3C:5E:27

# Connect IronVirus2
# nmcli device wifi connect B0:BE:76:41:31:7E password 'xeonserver2004!Roma10' ifname wlp3s0 --escape

# Connect IronVirus5Ghz
SSID="IronVirus5Ghz"
PASSWORD="xeonserver2004!Roma10"
nmcli device wifi connect "$SSID" password "$PASSWORD" hidden yes

# disconnect
# nmcli device disconnect ifname wlp3s0
