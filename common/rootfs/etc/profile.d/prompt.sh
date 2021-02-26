export PS1='$(resize > /dev/null)\h ($(tty|cut -d '/'  -f 3-4)) \w \n\$ '
stty -F /dev/ET_ROOTFS_GETTY_PORT sane
