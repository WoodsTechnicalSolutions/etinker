#!/bin/sh

# IPv4 / 24 -> a.b.c[.1] 
subnet=192.162.5

if [ -n "$1" ] && ! [ "$1" = "$subnet" ]; then
	subnet=$1
fi

# DNSMasq DHCP assigns '$subnet.2' (i.e. 192.168.5.2)
/sbin/route add default gw $subnet.2 2>/dev/null

if ! [ -n "`grep $subnet.2 /etc/resolv.conf 2>/dev/null`" ]; then
	echo "nameserver $subnet.2" >> /etc/resolv.conf
fi

cat /etc/resolv.conf

ip route show
