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
#   except-interface=enfoo
#   except-interface=wlfoo
#   server=1.2.3.4
#   domain=something.org
#   local=/something.org/
# ------------------------------
#

# IPv4 / 24 -> a.b.c[.1] 
subnet=192.168.5

if [ -n "$1" ] && ! [ "$1" = "$subnet" ]; then
	subnet=$1
fi

# Check given subnet based on route to device
if [ "`ip route get $subnet.1|cut -d ' ' -f 2|tr -d \\n`" = "via" ]; then
	echo Invalid subnet [$subnet]!
	exit 1
fi

# Enable IPv4 packet forwarding
echo "1" > /proc/sys/net/ipv4/ip_forward

ifdevice="`ip route get $subnet.1|cut -d ' ' -f 3|tr -d \\n`"
ifhost="`ip route show|grep default|tail -3|head -1|cut -d ' ' -f 5|tr -d \\n`"

if [ "$iphost" = "$ifdevice" ]; then
	ifhost="`ip route show|grep default|tail -2|head -1`"
	if [ "$iphost" = "$ifdevice" ]; then
		echo No default route!
		exit 1
	fi
fi

echo Using host interface $ifhost
echo Using device interface $ifdevice

iptables --table nat --append POSTROUTING --out-interface $ifhost -j MASQUERADE
iptables --append FORWARD --in-interface $ifdevice --out-interface $ifhost -j ACCEPT
iptables --append FORWARD --in-interface $ifhost --out-interface $ifdevice -m state --state RELATED,ESTABLISHED -j ACCEPT

ip route show
