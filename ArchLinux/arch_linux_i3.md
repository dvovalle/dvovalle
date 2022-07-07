# Instalando Arch Linux

> https://github.com/Airblader/i3

> Teclas de atalho básicas do i3
- https://elias.praciano.com/2014/08/teclas-de-atalho-do-i3/

Resolução do Notebook: 1920x1080 (16:9)


## Scripts Download

wget https://static.kalunga.com.br/libs/outros/oss/setup.txt

wget https://static.kalunga.com.br/libs/outros/oss/install.sh

## Configurando teclado

```bash

loadkeys br-abnt2
locale-gen
export LANG=en_US.UTF-8

timedatectl set-ntp true

```

## wifi

```bash

$ iwctl

[iwd]# device list

[iwd]# station wlp3s0 scan

[iwd]# station wlp3s0 get-networks

[iwd]# station wlp3s0 connect SSID

$ iwctl --passphrase passphrase station device connect IronVirus2

```

## Particionado HD

```bash
# para ver as partições
lsblk 

fdisk -l

fdisk -l /dev/sda

cfdisk /dev/sda


No meu caso ficou:

/dev/sda1 (500MB para o /boot/efi)

/dev/sda2 (150GB para /)

/dev/sda3 (todo o resto para o /home)

/dev/sda4 (8GB para swap)



mkfs.fat -n UEFI -F32 /dev/sda1

mkfs.ext4 -L ROOT /dev/sda2 

mkfs.ext4 -L HOME /dev/sda3

mkswap -L SWAP /dev/sda4 

```

## Encriptar partições

se deseja , pode realizar o cryptsetup

```bash

cryptsetup --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 root
mkfs.btrfs /dev/mapper/root

mount /dev/mapper/root /mnt

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

## Instalação

```bash
pacstrap /mnt base base-devel linux linux-firmware linux-header 

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

pacman -S dosfstools os-prober mtools network-manager-applet networkmanager wpa_supplicant wireless_tools dialog sudo vim curl wget base base-devel linux-header linux-firmware

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

## Config mkinitcpio

```bash

vim /etc/mkinitcpio.conf

# na linha
HOOKS=(base udev autodetec....   )  
# Incluir

HOOKS=(base udev autodetec.... keyboard keymap)  

sudo mkinitcpio -p linux


```

## Fechar e reinicializar o computador

Fechar e reinicializar o computador.

## Depois da instalação

```bash
systemctl enable NetworkManager
systemctl restart NetworkManager

pacman -Sy
pacman -Syyuu
pacman -S linux-header linux-firmware
pacman -S terminus-font
pacman -S dosfstools os-prober mtools network-manager-applet networkmanager 
pacman -S wpa_supplicant wireless_tools dialog sudo vim base base-devel 
pacman -S xorg-server xorg-xinit xorg-apps dmenu
pacman -S nvidia nvidia-utils nvidia-libgl mesa nvidia-settings vulkan-icd-loader
pacman -S bluez bluez-utils xdg-utils xdg-user-dirs alsa-utils 
pacman -S pulseaudio pulseaudio-bluetooth curl wget git vim
pacman -S i3-wm i3status i3blocks i3lock xfce4-terminal rofi fzf arandr xdotool
pacman -S wmctrl pcmanfm ranger thunar
pacman -S ttf-dejavu ttf-liberation noto-fonts
pacman -S firefox nitrogen picom lxappearance  
pacman -S material-gtk-theme papirus-icon-theme
pacman -S archlinux-wallpaper openconnect oath-toolkit

# rodar o comando, para gerar as pastas do usuario
xdg-user-dirs-update

# Se quiser instalar o lightdm
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings 

# Iniciar o i3 com startx
cp /etc/X11/xinit/xinitrc ~/.xinitrc
vim ~/.xinitrc
# comentar  a linha on esta 
# exec xterm -geometry 80x66+0+0 -name login
# e incluir 
exec i3



sudo vim /etc/lightdm/lightdm.conf

> descomantar a linha # display-setup-script=
display-setup-script=xrandr --output Virtual-1 --mode 1920x1080

systemctl enable lightdm

 
```



## Configurando o tamanho da resolução do monito

```bash

sudo vim /etc/default/grub

Alterar a linha: GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
para:  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet video=1920x1080"

sudo grub-mkconfig -o /boot/grub/grub.cfg

sudo systemctl reboot

xrandr --output HDMI-1 --mode 1920x1080 --right-of eDP-1


```

## Configuraçoes i3

```bash

setxkbmap ch

```


## Verificando firmware

```bash

sudo mkinitcpio -P
sudo mkinitcpio -p linux

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
