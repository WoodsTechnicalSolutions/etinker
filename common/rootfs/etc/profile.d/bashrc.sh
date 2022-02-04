shopt -s histappend
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist

export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoreboth:erasedups
export HISTTIMEFORMAT='%b %d %I:%M %p '
export HISTSIZE=5000
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls:history:cd ~:cd ..'

dynamic_prompt () {
	resize > /dev/null
	# cleanup bracketed paste stuff
	printf '\e[?2004l'
	# color settings
	rgb_restore='\[\033[00m\]'
	rgb_black='\[\033[00;30m\]'
	rgb_firebrick='\[\033[00;31m\]'
	rgb_red='\[\033[01;31m\]'
	rgb_forest='\[\033[00;32m\]'
	rgb_green='\[\033[01;32m\]'
	rgb_brown='\[\033[00;33m\]'
	rgb_yellow='\[\033[01;33m\]'
	rgb_navy='\[\033[00;34m\]'
	rgb_blue='\[\033[01;34m\]'
	rgb_purple='\[\033[00;35m\]'
	rgb_magenta='\[\033[01;35m\]'
	rgb_cadet='\[\033[00;36m\]'
	rgb_cyan='\[\033[01;36m\]'
	rgb_gray='\[\033[00;37m\]'
	rgb_white='\[\033[01;37m\]'

	rgb_std="${rgb_gray}"

	if [ `id -u` -eq 0 ]
	then
	    rgb_usr="${rgb_red}"
	else
	    rgb_usr="${rgb_forest}"
	fi

	uname_m="${rgb_magenta}`uname -m`"
	host_os="${rgb_white}[${rgb_cyan}etinker ${rgb_yellow}(${uname_m}${rgb_yellow})${rgb_white}]"
	host_tty="${rgb_yellow}`tty|cut -d '/'  -f 3-4`"

	export PS1="${rgb_usr}\u${rgb_white}@${rgb_green}\h${rgb_white}(${host_tty}${rgb_white}) ${host_os} ${rgb_yellow}\w \n${rgb_cyan}\\\$${rgb_restore} "

	unset   rgb_restore   \
		rgb_black     \
		rgb_firebrick \
		rgb_red       \
		rgb_forest    \
		rgb_green     \
		rgb_brown     \
		rgb_yellow    \
		rgb_navy      \
		rgb_blue      \
		rgb_purple    \
		rgb_magenta   \
		rgb_cadet     \
		rgb_cyan      \
		rgb_gray      \
		rgb_white     \
		rgb_std       \
		rgb_usr
}
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$"\n"}history -a; history -c; history -r; dynamic_prompt"

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
