#!/bin/bash
systemctl enable NetworkManager
systemctl restart NetworkManager

loadkeys br-abnt2
export LANG=en_US.UTF-8
timedatectl set-ntp true
hwclock --systohc

pacman -Syyuu

pacman -S terminus-font dosfstools os-prober mtools network-manager-applet networkmanager wpa_supplicant wireless_tools dialog sudo vim curl wget base base-devel linux-header linux-firmware nvidia nvidia-utils nvidia-libgl mesa nvidia-settings vulkan-icd-loader bluez bluez-utils xdg-utils xdg-user-dirs alsa-utils pulseaudio pulseaudio-bluetooth curl wget git vim