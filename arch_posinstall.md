# Arch Linux - Pós Instalação


https://github.com/Raymo111/i3lock-color
sudo pacman -S autoconf cairo fontconfig gcc libev libjpeg-turbo libxinerama libxkbcommon-x11 libxrandr pam pkgconf xcb-util-image xcb-util-xrm


## Install Yay

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sri
```

## Config Bash (ZSH)

> Install ZSH
```bash
echo $SHELL

sudo pacman -S zsh zsh-completions

```

> Config Powerlevel10k 

- https://github.com/romkatv/powerlevel10k#arch-linux

```bash
# Install Powerlevel10k
yay -S --noconfirm zsh-theme-powerlevel10k-git

# Install Fonts
yay -S ttf-meslo-nerd-font-powerlevel10k powerline-fonts awesome-terminal-fonts

# Criando ~/.zshrc
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

# Habilitar o ZSH
chsh -s /usr/bin/zsh

# Configurar conforme desejar
p10k configure

# Configurar o VIM como editor padrão
echo "bindkey -v" >> ~/.zshrc
echo "export EDITOR=/usr/bin/vim" >> ~/.zshrc
echo "export VISUAL=/usr/bin/vim" >> ~/.zshrc

source ~/.zshrc

```
