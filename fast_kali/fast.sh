

sudo apt update && sudo apt install -y \
nmap wireshark aircrack-ng hashcat hydra gobuster sqlmap \
john netcat-traditional tcpdump \
openvpn whois nikto \
postgresql postgresql-contrib libpq-dev
sudo systemctl enable --now postgresql

# essentials for metasploit
sudo apt install -y build-essential zlib1g zlib1g-dev libpq-dev libpcap-dev libsqlite3-dev ruby ruby-dev
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod +x msfinstall
sudo ./msfinstall
msfdb init


# kali tools...

