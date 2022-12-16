header(){
echo "SSH over Websocket Server Setup"
echo "https://github.com/mkp95/ppws"
echo ""
}

setup(){
echo "Installing Required Programs"
apt update && apt -y upgrade
apt -y install stunnel4 nodejs dropbear cmake make build-essential unzip certbot ufw gcc
}

setup_firewall(){
echo "Setting up Firewall"
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable
}

setup_dropbear(){
echo "Setting up Dropbear"
service dropbear stop
service dropbear start
service dropbear stop
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=40000/g' /etc/default/dropbear
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="/etc/banner.txt"/g' /etc/default/dropbear
echo 'Get Ready Babyyyy!' > /etc/banner.txt
service dropbear start
}

install_badvpn(){
echo "Setting up BadVPN"
wget -O badvpn.zip "https://codeload.github.com/mkp95/badvpn/zip/refs/heads/master"
unzip badvpn.zip
cd badvpn-master
mkdir build && cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
cd ../..
rm -r *
wget -O /etc/systemd/system/badvpn.service  "https://raw.githubusercontent.com/mkp95/ppws/main/badvpn.service"
systemctl enable badvpn.service
}

install_cert(){
echo "Enter domain: "
read domain
certbot certonly --standalone --preferred-challenges http -d $domain -m a@$domain --noninteractive --agree-tos
}

install_socket(){
echo "WebSocket Setup"
mkdir /etc/nodews
wget -O /etc/nodews/proxy3.js "https://raw.githubusercontent.com/mkp95/ppws/main/proxy3.js"
wget -O /etc/systemd/system/nodews.service "https://raw.githubusercontent.com/mkp95/ppws/main/nodews.service"
systemctl enable nodews.service
}

set_user(){
echo "Setting up User for SSH"
echo "Enter Username: "
read user
echo "Enter Pass: "
read pass
grep -Fx -q "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells
grep -Fx -q "/usr/sbin/nologin" /etc/shells || echo "/usr/sbin/nologin" >> /etc/shells
useradd -M $user -s /bin/false
chpasswd <<<"$user:$pass"
}

setup_stunnel(){
    echo "Setting up STunnel"
    wget -O /etc/stunnel/stunnel.conf "https://github.com/mkp95/ppws/raw/main/stunnel.conf"
    cp /etc/letsencrypt/live/$domain/privkey.pem  /etc/stunnel
    cp /etc/letsencrypt/live/$domain/cert.pem /etc/stunnel/
    chmod 600 /etc/stunnel/*.pem
}

start_service(){
stunnel
}

sshws_install(){
header
setup
setup_firewall
setup_dropbear
install_badvpn
install_cert
install_socket
set_user
setup_stunnel
start_service
echo "Reboot and Enjoy!!!"
}
sshws_install
