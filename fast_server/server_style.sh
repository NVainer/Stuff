#style
# 1) Deps (small)
sudo apt update && sudo apt-get upgrade -y
sudo apt install -y git sassc xfce4-whiskermenu-plugin libglib2.0-dev-bin libxml2-utils gtk2-engines-murrine figlet &&

# 2) Get the theme + install (Dark)
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -c dark     # installs "WhiteSur-Dark" into ~/.themes
# (Optional) also theme GTK4/libadwaita apps:
./install.sh -l -c dark
cd ..
sleep 1
# 3) (Optional) Icons to match
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh             # installs "WhiteSur" icons into ~/.local/share/icons
cd ..
sleep 1
# 4) Apply in XFCE (no GUI clicks)
xfconf-query -c xsettings -p /Net/ThemeName -s "WhiteSur-Dark" \
  || xfconf-query -c xsettings -n -p /Net/ThemeName -t string -s "WhiteSur-Dark"
xfconf-query -c xfwm4 -p /general/theme -s "WhiteSur-Dark" \
  || xfconf-query -c xfwm4 -n -p /general/theme -t string -s "WhiteSur-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur" \
  || xfconf-query -c xsettings -n -p /Net/IconThemeName -t string -s "WhiteSur"
xfce4-panel -r
sleep 2

# Hide Home
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home \
  --create -t bool -s false

# Hide File System
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem \
  --create -t bool -s false

# Hide Trash
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash \
  --create -t bool -s false

sleep 1
##Remove Panel 2 (fuck my life, that was a real pain)
#IDS=$(xfconf-query -c xfce4-panel -p /panels/panel-2/plugin-ids -v 2>/dev/null || echo)
#for i in $IDS; do xfconf-query -c xfce4-panel -p "/plugins/plugin-$i" -r -R 2>/dev/null; done
#xfconf-query -c xfce4-panel -p /panels/panel-2 -r -R 2>/dev/null
#xfconf-query -c xfce4-panel -p /panels -r
#xfconf-query -c xfce4-panel -n -p /panels -a -t int -s 1
#xfce4-panel -r


## top panel to bottom
#xfconf-query -c xfce4-panel -p /panels/panel-1/position -s "p=10;x=0;y=0"

# auto icon size
xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s 0 || \
xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s -1

## set dark mode
xfconf-query -c xfce4-panel -p /panels/dark-mode -s true 2>/dev/null || true

sleep 1
#change wallpaper
sudo curl -fsSL https://raw.githubusercontent.com/NVainer/Stuff/main/ClickNet_wallpaper.png \
  -o /usr/share/xfce4/backdrops/ClickNet_wallpaper.png
IMG="/usr/share/xfce4/backdrops/ClickNet_wallpaper.png"
for p in $(xfconf-query -c xfce4-desktop -l | grep -E '/(last-image|image-path)$'); do
  xfconf-query -c xfce4-desktop -p "$p" -s "$IMG"
done
for p in $(xfconf-query -c xfce4-desktop -l | grep '/image-style$'); do
  xfconf-query -c xfce4-desktop -p "$p" -s 5
done
xfdesktop --reload

#install brave
read -p "install Brave? (y/n): " install_brave
if [[ "${install_brave,,}" == "y" ]]; then
  sudo curl -fsS https://dl.brave.com/install.sh | sudo bash
fi

read -p "setup RDP server? (y/n): " install_rdp
if [[ "${install_rdp,,}" == "y" ]]; then
  echo "Disabling RDP service..."
  # Preseed gdm3 selection to avoid lightdm prompt
  echo "gdm3 shared/default-x-display-manager select gdm3" | sudo debconf-set-selections
  # Install RDP server and XFCE without prompts
  sudo DEBIAN_FRONTEND=noninteractive apt install -y xrdp xfce4 xfce4-goodies
  echo "startxfce4" > ~/.xsession
  chmod +x ~/.xsession
  sudo adduser xrdp ssl-cert
  sudo adduser $USER xrdp

  sudo systemctl enable xrdp
  sudo systemctl restart xrdp
  sudo ufw allow 3389/tcp
fi
sleep 1




#essential security
read -p "Care about security? (y/n): " install_sec
if [[ "${install_sec,,}" == "y" ]]; then
  sudo apt install -y timeshift gufw fail2ban apparmor apparmor-utils keepassxc
  sudo systemctl enable fail2ban apparmor
  sudo ufw enable
fi
sleep 1



read -p "install ZSH (better shell)? (y/n): " better_shell
if [[ "${better_shell,,}" == "y" ]]; then
  sudo apt install zsh-common zsh-doc zsh
  # making zsh default
  sudo chsh -s $(which zsh) "$USER"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # installing fonts
  mkdir -p ~/.local/share/fonts 
  cd ~/.local/share/fonts 
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip 
  unzip FiraCode.zip 
  rm FiraCode.zip 
  fc-cache -fv 
  cd ~

  # install powerlevel10k theme
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
  

  # pull my p10k script from my github my_p10k 
  curl -fsSL https://raw.githubusercontent.com/NVainer/fast_ubuntu/refs/heads/main/my_p10k.zsh -o ~/.p10k.zsh
  echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc
  echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
fi

rm -rf ./WhiteSur*


#install docker

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sleep 1

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER # (to run docker without sudo)
sleep 1

#add webcheck image yaml
cat > docker-compose.yml <<'EOF'
services:
  web-check:
    image: lissy93/web-check:latest
    container_name: web-check
    ports:
      - "3000:3000"
    restart: unless-stopped
EOF
sleep 1
sudo docker compose up -d
sleep 1

#whisker
xfce4-panel --add=whiskermenu || true &&
xfce4-panel -r


clear
echo -e "\e[1;32m"
figlet "All done!"
echo " "
echo " "
echo "It's time to logout/login ☺"
echo -e "\e[0m"
echo " "
echo " "
echo " "



read -p "Logout now? (y/n): " logout_now
if [[ "${logout_now,,}" == "y" ]]; then
  xfce4-session-logout --logout --fast
fi
