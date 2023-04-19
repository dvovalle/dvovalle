# Instalando Arch Linux

## Como criar pendrive bootavel Linux

Criando a particao do pendrive

- fdisk /dev/sdb
- remova as particoes existentes
- crie a particao do tipo gpt
- mkfs.fat -n DEBIAN -F 32 /dev/sdb1
- baixa a imagen iso
- so rodar o comando abaixo para gerara imagem

```bash
dd if=/home/usuario/Downloads/imagem.iso of=/dev/sdb status=progress && sync
```

## Configurando teclado

```bash

loadkeys br-abnt2
locale-gen
export LANG=en_US.UTF-8

timedatectl set-ntp true

```

## Particionado HD

```bash
fdisk -l

fdisk -l /dev/sda

cfdisk /dev/sda


No meu caso ficou:

/dev/sda1 (500MB para o /boot/efi)

/dev/sda2 (150GB para /)

/dev/sda3 (todo o resto para o /home)

/dev/sda4 (8GB para swap)



mkfs.fat -n UEFI -F 32 /dev/sda1

mkfs.ext4 -L ROOT /dev/sda2 

mkfs.ext4 -L HOME /dev/sda3

mkswap -L SWAP /dev/sda4 

```

## Pontos de montagem

O próximo passo é fazer a montagem das partições do sistema, atente-se que será necessário criar algumas pastas para poder fazer a montagem.

```bash
mount /dev/sda2 /mnt

mkdir /mnt/home

mkdir /mnt/boot

mkdir /mnt/boot/efi (se for usar EUFI) 

mount /dev/sda3 /mnt/home

mount /dev/sda1 /mnt/boot/efi

swapon /dev/sda4
```

## Config IP

> https://wiki.archlinux.org/title/Network_configuration


```bash

ip address show

# ADD
ip address add 172.20.80.84 broadcast + dev enp0s4

ip route add default via 172.20.80.254 dev enp0s4

# DEL

ip address del address/prefix_len dev interface
ip route del PREFIX via address dev interface

```

## Instalação

```bash
pacstrap /mnt base base-devel linux linux-firmware

genfstab -U -p /mnt >> /mnt/etc/fstab

```

## Chroot

Mude a raiz para novo sistema: 

```bash

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Execute hwclock(8) para gerar /etc/adjtime:

hwclock --systohc

 ```

## Localização

Edite /etc/locale.gen e descomente en_US.UTF-8 UTF-8 com qualquer outro locale necessário. Gere os locales executando:

```bash

# descomente en_US.UTF-8 UTF-8 
vim /etc/locale.gen
 

locale-gen

# Crie o arquivo locale.conf(5) e defina a variável LANG adequadamente:

echo LANG=en_US.UTF-8 >> /etc/locale.conf

# Se você definir o layout do teclado, torne as alterações persistentes em vconsole.conf(5):

echo KEYMAP=br-abnt2 >> /etc/vconsole.conf

# Nome da Maquina
vi /etc/hostname

# Arvio de hosts
vi /etc/hosts

127.0.0.1   localhost.dvo.com.br    localhost
::1         localhost.dvo.com.br    localhost
127.0.1.1   pcdvo.dvo.com.br        pcdvo


Vamos configurar agora a senha nova para o seu usuário root:

passwd


useradd -m -g users -G wheel danilo

```

## Instalando pacotes

Vamos aproveitar a ocasião para instalar alguns pacotes que serão úteis na pós instalação do sistema:

```bash

pacman -S dosfstools os-prober mtools network-manager-applet networkmanager wpa_supplicant wireless_tools dialog sudo vim curl wget

 vim /etc/sudoers

 danilo ALL=(ALL) ALL

```

## Instalando o GRUB 

> ##EUFI##

```bash
pacman -S grub-efi-x86_64 efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

cp /usr/share/locale/en@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

grub-mkconfig -o /boot/grub/grub.cfg

```

> Fechar e reinicializar o computador

## Depois da instalação

```bash
systemctl enable NetworkManager
systemctl restart NetworkManager

pacman -Sy
pacman -Syyuu
pacman -S xorg-server 

pacman -S nvidia nvidia-utils nvidia-libgl mesa nvidia-settings vulkan-icd-loader

##GNOME##

pacman -S gdm
systemctl enable gdm

pacman -S gnome gnome-terminal nautilus gnome-tweaks gnome-control-center gnome-backgrounds 
pacman -S gnome-software-packagekit-plugin
pacman -S adwaita-icon-theme vim curl wget git firefox
pacman -S noto-fonts
pacman -S bluez bluez-utils blueman


systemctl enable NetworkManager
systemctl enable bluetooth
systemctl start bluetooth

```

## Verificando firmware

```bash

sudo mkinitcpio -P
sudo mkinitcpio -p linux

 sudo pacman -S linux-firmware-qlogic

pacman -S linux-firmware
git clone https://aur.archlinux.org/wd719x-firmware.git
git clone https://aur.archlinux.org/aic94xx-firmware.git
git clone https://aur.archlinux.org/upd72020x-fw.git

```

## VPN

```bash
# openconnect: VPN COnnect
pacman -S openconnect

# oath
pacman -S oath-toolkit

# VPN Slice
git clone https://aur.archlinux.org/vpn-slice-git.git

```

## Archlinux

### Install pacakge

``` bash

sudo pacman -Sy yay base-devel xorg-xserver-devel

yay -S xrdp xorgxrdp-git xorgxrdp xorgxrdp-glamor

```

### /etc/X11/Xwrapper.config

``` conf

# ...

# Allow anybody to start X:
allowed_users=anybody

```

### /etc/xrdp/sesman.ini

``` conf
# ...
[Xorg]
param=/usr/lib/Xorg
# Leave the rest of the lines untouched
#...
```

### xinit

``` bash
cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

### ~/.xinitrc

``` conf

# ...

# !!! Remove several lines from "twm" to "xterm",
# !!! since we don't need them and they throw error if not removed

# Start Desktop Environment
exec dbus-launch --exit-with-session

```

### Enable + Restart services

``` bash
systemctl enable xrdp
systemctl enable xrdp-sesman
systemctl restart xrdp
systemctl restart xrdp-sesman
```
