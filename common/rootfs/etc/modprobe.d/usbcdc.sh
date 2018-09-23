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

		# Make Windows OS recognize the USB devices
		echo 0xEF > bDeviceClass
		echo 0x02 > bDeviceSubClass
		echo 0x01 > bDeviceProtocol

		mkdir -p strings/0x409
		grep -Eo '"serialnumber":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > strings/0x409/serialnumber
		grep -Eo '"manufacturer":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > strings/0x409/manufacturer
		grep -Eo '"product":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > strings/0x409/product

		mkdir -p configs/c.1/strings/0x409
		echo "Config 1: RNDIS network" > configs/c.1/strings/0x409/configuration
		echo 250 > configs/c.1/MaxPower
		# USB_OTG_SRP | USB_OTG_HNP
		echo 0x80 > configs/c.1/bmAttributes

		# MS Windows 10 RNDIS
		# - [http://irq5.io/2016/12/22/raspberry-pi-zero-as-multiple-usb-gadgets/]
		echo 1 > os_desc/use
		echo 0xcd > os_desc/b_vendor_code
		echo MSFT100 > os_desc/qw_sign

		# Ethernet (RNDIS)
		mkdir -p functions/rndis.usb0
		# taken from Debian's am335x_evm boot scripts
		if [ -f functions/rndis.usb0/class ]; then
			echo EF > functions/rndis.usb0/class
			echo 04 > functions/rndis.usb0/subclass
			echo 01 > functions/rndis.usb0/protocol
		fi
		echo RNDIS > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
		echo 5162001 > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id
		ln -s configs/c.1 os_desc
		grep -Eo '"host_addr":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > functions/rndis.usb0/host_addr
		grep -Eo '"dev_addr":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4 > functions/rndis.usb0/dev_addr
		ln -s functions/rndis.usb0 configs/c.1/

		# Serial (ACM)
		list="`grep -Eo '"acm":.*?[^\\]",' /etc/etinker.conf | cut -d '"' -f 4`"
		for i in $list;  do
			mkdir -p functions/acm.gs$i
			ln -s functions/acm.gs$i configs/c.1/
		done

		udevadm settle -t 5 || :

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
