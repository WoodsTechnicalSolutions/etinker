export PS1='$(resize > /dev/null)\h ($(tty|cut -d '/'  -f 3-4)) \w \n\$ '
stty -F /dev/ttyS0 sane
