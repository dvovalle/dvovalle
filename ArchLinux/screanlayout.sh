#!/bin/sh

# Configura layout do teclado
setxkbmap -model pc105 -layout br -option grp:alt_caps_toggle

# Configuração do meu monitor
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-1 --off --output HDMI-2 --off
