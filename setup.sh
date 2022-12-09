#install packages
apt update && apt -y upgrade
apt -y install stunnel4 nodejs dropbear cmake make build-essential unzip certbot ufw gcc


#setup firewall
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable

#setup dropbear
wget -O dropbear https://raw.githubusercontent.com/mkp95/ppws/main/dropbear
mv dropbear /etc/default/dropbear

#install badvpn
wget -O badvpn.zip https://codeload.github.com/mkp95/badvpn/zip/refs/heads/master
unzip badvpn.zip
cd badvpn-master
mkdir build && cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
wget -O badvpn.service  https://raw.githubusercontent.com/mkp95/ppws/main/badvpn.service

#setup certs for stunnel
wget -O stunnel.conf https://raw.githubusercontent.com/mkp95/ppws/main/stunnel.conf
mv stunnel.conf /etc/stunnel.conf
certbot certonly --standalone --preferred-challenges http -d domain
cp /etc/letsencrypt/live/domain/privkey.pem  /etc/stunnel
cp /etc/letsencrypt/live/domain/cert.pem /etc/stunnel/
chmod 600 /etc/stunnel/*.pem

#setup nodews
mkdir /etc/nodews
wget -O /etc/nodews/proxy3.js https://raw.githubusercontent.com/mkp95/ppws/main/proxy3.js
wget -O nodews.service  https://raw.githubusercontent.com/mkp95/ppws/main/nodews.service

#enable services
cp *.service /systemd/system/
systemctl enable nodews.service
systemctl enable badvpn.service

#setup blank shell
grep -Fx -q "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells

#add new user
useradd -M user -s /bin/false
chpasswd <<<"user:123"
