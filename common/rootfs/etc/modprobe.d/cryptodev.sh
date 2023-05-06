module="cryptodev"
options=""
if [ -d /lib/modules/`uname -r`/updates ]; then
	ko="/lib/modules/`uname -r`/updates/$module.ko"
else
	ko="/lib/modules/`uname -r`/extra/$module.ko"
fi
if [ -f $ko ]; then
	case "$1" in
	start)
		modprobe -v $module "$options"
		;;
	stop)
		modprobe -r $module
		;;
	*)
		;;
	esac
	exit 0
else
	printf "modules: missing %s!\n" "$module"
	exit 1
fi
