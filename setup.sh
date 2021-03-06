#apt-get -y update
#apt-get -y upgrade
#passwd
#apt-get -y install iptables-persistent
#apt-get -y install isc-dhcp-server
#apt-get -y install git
apt-get -y install wide-dhcpv6-client

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


service isc-dhcp-server restart

netstat -anpu
netstat -anpt

echo 'source-directory /etc/network/interfaces.d' > /etc/network/interfaces
echo 'auto lo' >> /etc/network/interfaces
echo 'iface lo inet loopback' >> /etc/network/interfaces
echo 'auto eth1 ' >> /etc/network/interfaces
echo 'iface eth1 inet static' >> /etc/network/interfaces
echo ' address 10.114.67.254' >> /etc/network/interfaces
echo ' netmask 255.255.252.0' >> /etc/network/interfaces
echo 'auto eth0' >> /etc/network/interfaces
echo 'iface eth0 inet dhcp' >> /etc/network/interfaces
echo 'iface eth0 inet6 static' >> /etc/network/interfaces
echo 'allow-hotplug wlan0' >> /etc/network/interfaces
echo 'iface wlan0 inet manual' >> /etc/network/interfaces
echo '    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
echo 'allow-hotplug wlan1' >> /etc/network/interfaces
echo 'iface wlan1 inet manual' >> /etc/network/interfaces
echo '    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
#echo 'up iptables-restore < /etc/iptables.ipv4.nat' >> /etc/network/interfaces
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
#echo 'net.ipv6.conf.eth0.accept_ra=2' >> /etc/sysctl.conf

echo 'interface eth0 { # external facing interface (WAN)' > /etc/wide-dhcp6c/dhcp6c.conf
echo '  send ia-na 1;' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  send ia-pd 1;' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  request domain-name-servers;' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  request domain-name;' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  script "/etc/wide-dhcpv6/dhcp6c-script";' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '};' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '' >> /etc/wide-dhcp6c/dhcp6c.conf
echo 'id-assoc pd 1 {' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  prefix-interface eth1 { #internal facing interface (LAN)' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '    sla-id 0; # subnet. Combined with ia-pd to configure the subnet for this interface.' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '    ifid 1; #IP address "postfix". if not set it will use EUI-64 address of the interface. Combined with SLA-ID'd prefix to create full IP address of interface.' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '    sla-len 8; # prefix bits assigned. Take the prefix size you're assigned (something like /48 or /56) and subtract it from 64. In my case I was being assigned a /56, so 64-56=8' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '    };' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  };' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  id-assoc na 1 {' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '  # id-assoc for eth1' >> /etc/wide-dhcp6c/dhcp6c.conf
echo '};' >> /etc/wide-dhcp6c/dhcp6c.conf



sudo chown root:root /etc/network/if-pre-up.d/iptables && sudo chmod +x /etc/network/if-pre-up.d/iptables && sudo chmod 755 /etc/network/if-pre-up.d/iptables
sudo iptables --flush
sudo ip6tables --flush
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

# loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -d 127.0.0.1 -j ACCEPT
iptables -A OUTPUT -s 127.0.0.1 -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -s ::1 -d ::1 -j ACCEPT
ip6tables -A OUTPUT -s ::1 -d ::1 -j ACCEPT

# ACCEPT already ESTABLISHED connections
iptables -A INPUT -p ALL -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p ALL -i eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -p ALL -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -p ALL -i eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

# ACCEPT all OUTPUT
iptables -A OUTPUT -p ALL -o eth0 -j ACCEPT
iptables -A OUTPUT -p ALL -o eth1 -j ACCEPT
ip6tables -A OUTPUT -p ALL -o eth0 -j ACCEPT
ip6tables -A OUTPUT -p ALL -o eth1 -j ACCEPT

# SSH
iptables -A INPUT -p tcp -i eth1 --dport 22 -m state --state NEW -j ACCEPT
ip6tables -A INPUT -p tcp -i eth1 --dport 22 -m state --state NEW -j ACCEPT

# ICMP
iptables -A INPUT -i eth1 -p icmp -m icmp --icmp-type 8 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp -j ACCEPT

#sudo iptables -A INPUT -i eth1 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -i eth0 -j DROP
sudo iptables -A FORWARD -s 192.168.0.0/16 -i eth0 -j DROP
sudo iptables -A INPUT -s 10.0.0.0/8 -i eth0 -j DROP
sudo iptables -A FORWARD -s 10.0.0.0/8 -i eth0 -j DROP
sudo iptables -A INPUT -s 172.16.0.0/12 -i eth0 -j DROP
sudo iptables -A FORWARD -s 172.16.0.0/12 -i eth0 -j DROP
sudo iptables -A INPUT -s 224.0.0.0/4 -i eth0 -j DROP
sudo iptables -A FORWARD -s 224.0.0.0/4 -i eth0 -j DROP
sudo iptables -A INPUT -s 240.0.0.0/5 -i eth0 -j DROP
sudo iptables -A FORWARD -s 240.0.0.0/5 -i eth0 -j DROP
sudo iptables -A INPUT -s 127.0.0.0/8 -i eth0 -j DROP
sudo iptables -A FORWARD -s 127.0.0.0/8 -i eth0 -j DROP
#sudo iptables -A INPUT -i eth0 -p icmp -m icmp --icmp-type 8 -j DROP

#sudo ip6tables -A INPUT -i eth0 -p tcp -m tcp -j DROP

sudo sh -c "iptables-save > /etc/iptables/rules.v4"
sudo sh -c "ip6tables-save > /etc/iptables/rules.v6"

#echo 'iptables-restore < /etc/iptables.ipv4.nat' > /etc/network/if-pre-up.d/iptables
#echo 'exit 0' >> /etc/network/if-pre-up.d/iptables
#rm /etc/network/if-pre-up.d/iptables
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf
#apt-get -y install locate
#apt-get -y install radvd
echo 'interface eth1' > /etc/radvd.conf
echo '{' >> /etc/radvd.conf
echo '     AdvSendAdvert on;' >> /etc/radvd.conf
echo '     AdvHomeAgentFlag off;' >> /etc/radvd.conf
echo '     MinRtrAdvInterval 30;' >> /etc/radvd.conf
echo '     MaxRtrAdvInterval 100;' >> /etc/radvd.conf
echo '     prefix 2601:640:8000:24bd::/64' >> /etc/radvd.conf
echo '     {' >> /etc/radvd.conf
echo '          AdvOnLink on;' >> /etc/radvd.conf
echo '          AdvAutonomous on;' >> /etc/radvd.conf
echo '          AdvRouterAddr on;' >> /etc/radvd.conf
echo '     };' >> /etc/radvd.conf
echo '};' >> /etc/radvd.conf
service radvd restart
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
#net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#
