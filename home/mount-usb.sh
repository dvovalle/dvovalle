#!/bin/bash

lsblk -f

# sudo mount -U C74E-07F7 /mnt/usbstick/disk01

sudo mount --source /dev/sr0 /mnt/usbstick/
