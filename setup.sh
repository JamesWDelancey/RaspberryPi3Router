#apt-get -y update
#apt-get -y upgrade
#passwd
apt-get -y install iptables-persistent
apt-get -y install isc-dhcp-server
apt-get -y install git

echo 'ddns-update-style none;' > /etc/dhcp/dhcpd.conf
echo 'authoritative;' >> /etc/dhcp/dhcpd.conf
echo 'max-lease-time 7200;' >> /etc/dhcp/dhcpd.conf
echo 'subnet 10.114.64.0 netmask 255.255.252.0 {' >> /etc/dhcp/dhcpd.conf
echo '    range 10.114.67.100 10.114.67.200;' >> /etc/dhcp/dhcpd.conf
#echo '    option tftp-server-name "10.1.1.5";' >> /etc/dhcp/dhcpd.conf
#echo '    option bootfile-name "2c:23:3a:5b:74:52_boot.py";' >> /etc/dhcp/dhcpd.conf
echo '    option broadcast-address 10.114.67.255;' >> /etc/dhcp/dhcpd.conf
echo '    option domain-name "jamesdelancey.com";' >> /etc/dhcp/dhcpd.conf
echo '    option domain-name-servers 75.75.75.75, 75.75.76.76;' >> /etc/dhcp/dhcpd.conf
echo '    default-lease-time 600;' >> /etc/dhcp/dhcpd.conf
echo '    max-lease-time 7200;' >> /etc/dhcp/dhcpd.conf

echo '    option routers 10.114.67.254;}' >> /etc/dhcp/dhcpd.conf

##switch1
#echo 'host host1 {' >> /etc/dhcp/dhcpd.conf
#echo '    option broadcast-address 10.1.1.255;' >> /etc/dhcp/dhcpd.conf
#echo '    hardware ethernet 2c:23:3a:5b:74:52;' >> /etc/dhcp/dhcpd.conf
#echo '    fixed-address 10.1.1.11;' >> /etc/dhcp/dhcpd.conf
#echo '    option tftp-server-name "10.1.1.5";' >> /etc/dhcp/dhcpd.conf
#echo '    option bootfile-name "2c:23:3a:5b:74:52_boot.py";}' >> /etc/dhcp/dhcpd.conf
#service isc-dhcp-server restart


service isc-dhcp-server stop

netstat -anpu
netstat -anpt

echo 'source-directory /etc/network/interfaces.d' > /etc/network/interfaces
echo 'auto lo' >> /etc/network/interfaces
echo 'iface lo inet loopback' >> /etc/network/interfaces
echo 'auto eth0 ' >> /etc/network/interfaces
echo 'iface eth0 inet static' >> /etc/network/interfaces
echo ' address 10.114.67.254' >> /etc/network/interfaces
echo ' netmask 255.255.252.0' >> /etc/network/interfaces
echo 'auto eth1' >> /etc/network/interfaces
echo 'iface eth1 inet dhcp' >> /etc/network/interfaces
#echo 'iface eth1 inet6 dhcp' >> /etc/network/interfaces
echo 'allow-hotplug wlan0' >> /etc/network/interfaces
echo 'iface wlan0 inet manual' >> /etc/network/interfaces
echo '    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
echo 'allow-hotplug wlan1' >> /etc/network/interfaces
echo 'iface wlan1 inet manual' >> /etc/network/interfaces
echo '    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
#echo 'up iptables-restore < /etc/iptables.ipv4.nat' >> /etc/network/interfaces
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

sudo chown root:root /etc/network/if-pre-up.d/iptables && sudo chmod +x /etc/network/if-pre-up.d/iptables && sudo chmod 755 /etc/network/if-pre-up.d/iptables
sudo iptables --flush
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -i eth1  -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT


#sudo iptables -A INPUT -i eth0 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -i eth1 -j DROP
sudo iptables -A INPUT -s 10.0.0.0/8 -i eth1 -j DROP
sudo iptables -A INPUT -s 172.16.0.0/12 -i eth1 -j DROP
sudo iptables -A INPUT -s 224.0.0.0/4 -i eth1 -j DROP
sudo iptables -A INPUT -s 240.0.0.0/5 -i eth1 -j DROP
sudo iptables -A INPUT -s 127.0.0.0/8 -i eth1 -j DROP
sudo iptables -A INPUT -i eth1 -p tcp -m tcp -j DROP
sudo iptables -A INPUT -i eth1 -p icmp -m icmp --icmp-type 8 -j DROP

sudo ip6tables -A INPUT -i eth1 -p tcp -m tcp -j DROP
#sudo ip6tables --flush

sudo sh -c "iptables-save > /etc/iptables/rules.v4"
sudo sh -c "ip6tables-save > /etc/iptables/rules.v6"

#echo 'iptables-restore < /etc/iptables.ipv4.nat' > /etc/network/if-pre-up.d/iptables
#echo 'exit 0' >> /etc/network/if-pre-up.d/iptables
#rm /etc/network/if-pre-up.d/iptables
#sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf
#apt-get -y install locate
#apt-get -y install radvd
