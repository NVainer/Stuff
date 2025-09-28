# make theme/icon system-wide so non-sudo users can use them
sudo mkdir -p /usr/share/themes /usr/share/icons /usr/local/share/fonts /usr/share/xfce4/backdrops

# if your installs live under your main user's home, copy them system-wide:
sudo cp -r /home/<MAINUSER>/.themes/WhiteSur* /usr/share/themes/ 2>/dev/null || true
sudo cp -r /home/<MAINUSER>/.local/share/icons/WhiteSur* /usr/share/icons/ 2>/dev/null || true

# wallpaper already placed by your script; re-copy just in case:
sudo cp /usr/share/xfce4/backdrops/ClickNet_wallpaper.png /usr/share/xfce4/backdrops/ClickNet_wallpaper.png

# (optional) make Nerd Fonts system-wide (instead of per-user)
if [ -d "/home/<MAINUSER>/.local/share/fonts" ]; then
  sudo cp -r /home/<MAINUSER>/.local/share/fonts/* /usr/local/share/fonts/
  sudo fc-cache -fv
fi

# create the per-user apply script (runs in user session, uses xfconf-query)
sudo tee /usr/local/bin/clicknet-xfce-apply.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
set -e

FLAG="$HOME/.config/.clicknet_xfce_applied"
IMG="/usr/share/xfce4/backdrops/ClickNet_wallpaper.png"

# only run once
[ -f "$FLAG" ] && exit 0

# theme + icons
xfconf-query -c xsettings -p /Net/ThemeName -s "WhiteSur-Dark" \
  || xfconf-query -c xsettings -n -p /Net/ThemeName -t string -s "WhiteSur-Dark"
xfconf-query -c xfwm4 -p /general/theme -s "WhiteSur-Dark" \
  || xfconf-query -c xfwm4 -n -p /general/theme -t string -s "WhiteSur-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur" \
  || xfconf-query -c xsettings -n -p /Net/IconThemeName -t string -s "WhiteSur"

# panel tweaks
xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s 0 || \
xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s -1
xfconf-query -c xfce4-panel -p /panels/dark-mode -s true 2>/dev/null || true

# hide desktop icons
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home --create -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem --create -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash --create -t bool -s false

# wallpaper
for p in $(xfconf-query -c xfce4-desktop -l | grep -E '/(last-image|image-path)$'); do
  xfconf-query -c xfce4-desktop -p "$p" -s "$IMG"
done
for p in $(xfconf-query -c xfce4-desktop -l | grep '/image-style$'); do
  xfconf-query -c xfce4-desktop -p "$p" -s 5
done

# refresh
xfce4-panel -r || true
xfdesktop --reload || true

mkdir -p "$(dirname "$FLAG")"
touch "$FLAG"
exit 0
EOF
sudo chmod +x /usr/local/bin/clicknet-xfce-apply.sh

# create a system-wide autostart entry so it runs for every user on next login
sudo tee /etc/xdg/autostart/clicknet-xfce-apply.desktop >/dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=ClickNet XFCE Apply
Exec=/usr/local/bin/clicknet-xfce-apply.sh
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF


sudo tee /usr/local/bin/clicknet-enable-zsh.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
set -e
# install oh-my-zsh + plugins in user space; change shell (prompts for user password)
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
curl -fsSL https://raw.githubusercontent.com/NVainer/fast_ubuntu/refs/heads/main/my_p10k.zsh -o ~/.p10k.zsh
echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
echo "Now run: chsh -s $(which zsh)"
EOF
sudo chmod +x /usr/local/bin/clicknet-enable-zsh.sh
