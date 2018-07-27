module="libcomposite"
options=""
ko="/lib/modules/`uname -r`/kernel/drivers/usb/gadget/$module.ko"
if [ -f $ko ]; then
	case "$1" in
	start)
		if ! [ -f /etc/etinker.conf ]; then
			printf "usbcdc: No configuration.\n"
			exit 0
		fi

		modprobe -v $module "$options"

		cd /sys/kernel/config/usb_gadget/
		mkdir -p etinker
		cd etinker
		echo 0x1d6b > idVendor  # Linux Foundation
		echo 0x0104 > idProduct # Multifunction Composite Gadget
		echo 0x0100 > bcdDevice # v1.0.0
		echo 0x0200 > bcdUSB    # USB2
		mkdir -p strings/0x409
		grep -Eo '"serialnumber":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > strings/0x409/serialnumber
		grep -Eo '"manufacturer":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > strings/0x409/manufacturer
		grep -Eo '"product":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > strings/0x409/product
		mkdir -p configs/c.1/strings/0x409
		echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
		echo 250 > configs/c.1/MaxPower
        
		# Serial (ACM)
		list="`grep -Eo '"acm":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4`"
		for i in $list;  do
			mkdir -p functions/acm.gs$i
			ln -s functions/acm.gs$i configs/c.1/
		done

		# Ethernet (ECM)
		mkdir -p functions/ecm.usb0
		grep -Eo '"host_addr":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > functions/ecm.usb0/host_addr
		grep -Eo '"dev_addr":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > functions/ecm.usb0/dev_addr
		ln -s functions/ecm.usb0 configs/c.1/
        
		# Startup
		ls /sys/class/udc > UDC

		;;
	stop)
		;;
	*)
		;;
	esac
	exit 0
else
	printf "usbcdc: modules missing %s!\n" "$module"
	exit 1
fi
