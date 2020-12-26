#!/bin/sh
#
# For a real DNS setup, on your development host, consider 'dnsmasq':
#
# [dnsmasq]
# - http://www.thekelleys.org.uk/dnsmasq/doc.html
# - https://wiki.archlinux.org/index.php/Dnsmasq
#
# [/etc/dnsmasq.conf - example]
# ------------------------------
#   no-resolv
#   expand-hosts
#   bind-interfaces
#   except-interface=enpfoo
#   except-interface=wlfoo
#   server=1.2.3.4
#   domain=something.org
#   local=/something.org/
# ------------------------------
#

# IPv4 / 24 -> a.b.c[.1] 
subnet=192.162.5

if [ -n "$1" ] && ! [ "$1" = "$subnet" ]; then
	subnet=$1
fi

# Enable IPv4 packet forwarding
echo "1" > /proc/sys/net/ipv4/ip_forward

ifhost="enp`route -n|grep UG|sed -n s/.*enp//p`"
ifpb="enp`route -n|grep $subnet|sed -n s/.*enp//p`"

iptables --table nat --append POSTROUTING --out-interface $ifhost -j MASQUERADE
iptables --append FORWARD --in-interface $ifpb --out-interface $ifhost -j ACCEPT
iptables --append FORWARD --in-interface $ifhost --out-interface $ifpb -m state --state RELATED,ESTABLISHED -j ACCEPT

ip route show
