# variables.bash

# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)

export CLICOLOR=1
export CLICOLOR_FORCE=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export LS_COLORS+=':ow=01;33'

export EDITOR=vim 
export MANPAGER="less -X"
export EMAIL="$USER@sissa.it"

export HISTFILESIZE=10000                     # Increase the max no of lines
export HISTCONTROL="ignoredups:erasedups"     # Ignore duplic commands in history

export LC_ALL=en_US.UTF-8 					  # remedy to import matplotlib error messages
export LANG=en_US.UTF-8 					  # remedy to import matplotlib error messages
export LC_CTYPE=en_US.UTF-8
