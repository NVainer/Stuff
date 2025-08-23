sudo apt update && sudo apt upgrade -y
sudo apt install -y xfce4 xfce4-goodies xfce4-session
sudo apt purge -y lightdm # to prevent this shit from conflict startup
sudo DEBIAN_FRONTEND=noninteractive apt install -y gdm3

# Set default session for GDM3 (match the file name in /usr/share/xsessions/)
sudo sed -i 's/^#\?DefaultSession=.*/DefaultSession=xfce.desktop/' /etc/gdm3/custom.conf || \
echo -e "[daemon]\nDefaultSession=xfce.desktop" | sudo tee -a /etc/gdm3/custom.conf

# always start XFCE
echo -e "[User]\nXSession=xfce" | sudo tee /var/lib/AccountsService/users/$USER
sudo chmod 644 /var/lib/AccountsService/users/$USER
echo "xfce4-session" > ~/.xsession && chmod +x ~/.xsession

sudo systemctl enable gdm3
sudo reboot
