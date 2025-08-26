#style
# 1) Deps (small)
sudo apt update
sudo apt install -y git sassc libglib2.0-dev-bin libxml2-utils gtk2-engines-murrine

# 2) Get the theme + install (Dark)
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -c dark     # installs "WhiteSur-Dark" into ~/.themes
# (Optional) also theme GTK4/libadwaita apps:
./install.sh -l -c dark
cd ..

# 3) (Optional) Icons to match
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh             # installs "WhiteSur" icons into ~/.local/share/icons
cd ..

# 4) Apply in XFCE (no GUI clicks)
xfconf-query -c xsettings -p /Net/ThemeName -s "WhiteSur-Dark" \
  || xfconf-query -c xsettings -n -p /Net/ThemeName -t string -s "WhiteSur-Dark"
xfconf-query -c xfwm4 -p /general/theme -s "WhiteSur-Dark" \
  || xfconf-query -c xfwm4 -n -p /general/theme -t string -s "WhiteSur-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur" \
  || xfconf-query -c xsettings -n -p /Net/IconThemeName -t string -s "WhiteSur"
xfce4-panel -r






## install themes
#sudo apt install -y xfce4-whiskermenu-plugin papirus-icon-theme arc-theme &&

## apply
#xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Darker"
#xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
#xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Breeze"
#xfconf-query -c xfwm4 -p /general/theme -s "Arc-Darker"


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
#xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark" \
#  || xfconf-query -c xsettings -n -p /Net/ThemeName -t string -s "Arc-Dark"
#xfconf-query -c xfwm4 -p /general/theme -s "Arc-Dark" \
#  || xfconf-query -c xfwm4 -n -p /general/theme -t string -s "Arc-Dark"
#gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

#whisker
xfce4-panel --add=whiskermenu || true &&
xfce4-panel -r

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
sudo curl -fsS https://dl.brave.com/install.sh | sudo bash




