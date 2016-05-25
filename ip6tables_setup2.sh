# First, delete all:
ip6tables -F
ip6tables -X

# Allow anything on the local link
ip6tables -A INPUT  -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Allow anything out on the internet
ip6tables -A OUTPUT -o eth1 -j ACCEPT
# Allow established, related packets back in
ip6tables -A INPUT  -i eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow the localnet access us:
ip6tables -A INPUT    -i eth0   -j ACCEPT
ip6tables -A OUTPUT   -o eth0   -j ACCEPT

# Filter all packets that have RH0 headers:
ip6tables -A INPUT -m rt --rt-type 0 -j DROP
ip6tables -A FORWARD -m rt --rt-type 0 -j DROP
ip6tables -A OUTPUT -m rt --rt-type 0 -j DROP

# Allow Link-Local addresses
ip6tables -A INPUT -s fe80::/10 -j ACCEPT
ip6tables -A OUTPUT -s fe80::/10 -j ACCEPT

# Allow multicast
ip6tables -A INPUT -d ff00::/8 -j ACCEPT
ip6tables -A OUTPUT -d ff00::/8 -j ACCEPT

# Allow ICMPv6 everywhere
ip6tables -I INPUT  -p icmpv6 -j ACCEPT
ip6tables -I OUTPUT -p icmpv6 -j ACCEPT
ip6tables -I FORWARD -p icmpv6 -j ACCEPT

# Allow forwarding
ip6tables -A FORWARD -m state --state NEW -i eth0 -o eth1 -s 2601:640:8000:24bd::/64 -j ACCEPT
ip6tables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH in
#ip6tables -A FORWARD -i sixxs -p tcp -d <subnet-prefix>::5 --dport 22 -j ACCEPT

# Bittorrent
#ip6tables -A FORWARD -i sixxs -p tcp -d <subnet-prefix>::5 --dport 33600:33604 -j ACCEPT

# Set the default policy
ip6tables -P INPUT   DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT  DROP
