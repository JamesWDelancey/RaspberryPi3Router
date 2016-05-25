#!/bin/sh

# Flush & default
ip6tables -F INPUT
ip6tables -F OUTPUT
ip6tables -F FORWARD
ip6tables -F

# Set the default policy to accept
ip6tables -P INPUT ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -P FORWARD ACCEPT

# Enable the following lines only if a router!
# Enabling IPv6 forwarding disables route-advertisement reception.
# A static gateway will need to be assigned.
#
#echo "1" >/proc/sys/net/ipv6/conf/all/forwarding
#
#End router forwarding rules

# Disable processing of any RH0 packet
# Which could allow a ping-pong of packets
ip6tables -A INPUT -m rt --rt-type 0 -j DROP
ip6tables -A OUTPUT -m rt --rt-type 0 -j DROP
ip6tables -A FORWARD -m rt --rt-type 0 -j DROP

# Allow anything on the local link
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Allow Link-Local addresses
ip6tables -A INPUT -s fe80::/10 -j ACCEPT
ip6tables -A OUTPUT -s fe80::/10 -j ACCEPT

# Allow multicast
ip6tables -A INPUT -d ff00::/8 -j ACCEPT
ip6tables -A OUTPUT -d ff00::/8 -j ACCEPT

# Allow ICMP
ip6tables -A INPUT -p icmpv6 -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 -j ACCEPT
ip6tables -A FORWARD -p icmpv6 -j ACCEPT

# Disable privileged ports for the outside, except ports 22, 515, and 631
# Specifying an interface (-i ethX) is probably a good idea to specify what is the outside
ip6tables -A INPUT -p tcp --dport 1:21 -j REJECT
ip6tables -A INPUT -p udp --dport 1:21 -j REJECT
ip6tables -A INPUT -p tcp --dport 23:514 -j REJECT
ip6tables -A INPUT -p udp --dport 23:514 -j REJECT
ip6tables -A INPUT -p tcp --dport 516:630 -j REJECT
ip6tables -A INPUT -p udp --dport 516:630 -j REJECT
ip6tables -A INPUT -p tcp --dport 632:1024 -j REJECT
ip6tables -A INPUT -p udp --dport 632:1024 -j REJECT
