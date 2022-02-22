# prompt.sh

# See also https://bashrcgenerator.com

# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)

#   Change Prompt
function prompt {
  local BLACK="\[\033[0;30m\]"
  local BLACKBOLD="\[\033[1;30m\]"
  local RED="\[\033[0;31m\]"
  local REDBOLD="\[\033[1;31m\]"
  local GREEN="\[\033[0;32m\]"
  local GREENBOLD="\[\033[1;32m\]"
  local YELLOW="\[\033[0;33m\]"
  local YELLOWBOLD="\[\033[1;33m\]"
  local BLUE="\[\033[0;34m\]"
  local BLUEBOLD="\[\033[1;34m\]"
  local PURPLE="\[\033[0;35m\]"
  local PURPLEBOLD="\[\033[1;35m\]"
  local CYAN="\[\033[0;36m\]"
  local CYANBOLD="\[\033[1;36m\]"
  local WHITE="\[\033[0;37m\]"
  local WHITEBOLD="\[\033[1;37m\]"
  local RESETCOLOR="\[\e[00m\]"

  local iRED="\[\033[7;31m\]"
  local iPURPLE="\[\033[7;35m\]"
  local iBLUE="\[\033[7;34m\]"

function job_indicator {
    p=$(squeue -l -u $USER | grep PENDING | wc -l)
    r=$(squeue -l -u $USER | grep RUNNING | wc -l)
    #⏰
    if [ "$p" -gt "0" ]; then
    P=☾
    else
    P=''
    fi
    if [ "$r" -gt "0" ]; then
    R=⭑ 
    else
    R=''
    fi

    tmp=$(echo "$P$R")
    if [ "${#tmp}" -gt "0" ]; then
      echo -e " $tmp "
    fi
}

  #export PS1="$RESETCOLOR $RED\u$GREENBOLD@\h:$BLUE\w$RESETCOLOR\$(job_indicator)$ "
  export PS1="$RESETCOLOR $GREENBOLD@\h:$BLUE\w$RESETCOLOR\$(job_indicator)$ "
}

prompt
