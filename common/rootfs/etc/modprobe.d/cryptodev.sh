module="cryptodev"
options=""
ko="/lib/modules/`uname -r`/extra/$module.ko"
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
