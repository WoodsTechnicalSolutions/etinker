module="cryptodev"
ko="/lib/modules/`uname -r`/extra/$module.ko"
if [ -f $ko ]; then
	modprobe -v $module
	exit 0
else
	printf "modules: missing %s!\n" "$module"
	exit 1
fi
