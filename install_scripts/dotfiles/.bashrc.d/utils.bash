# utils.bash

# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)

shopt -s histappend         	# Merge histories of all terminals into one
shopt -s autocd             	# Typing a dir name will CD into that dir
shopt -s cdspell            	# fix directory name typos when changing directory
shopt -s direxpand dirspell 	# xpand dir globs & fix dir name typos whilst completing

set show-all-if-ambiguous on 	# autocomplete w/o case-sensitivity
set completion-ignore-case on 	# autocomplete w/o case-sensitivity

psa () { # quick function as: ps aux | grep PROCESS_NAME. (Usage: psa NAME)
  ps aux | grep $1 | grep -v grep
}


kp () { # kill processes by name (as pkill but with output) (Usage: kp NAME)
  ps aux | grep $1 > /dev/null
  mypid=$(pidof $1)
  if [ "$mypid" != "" ]; then
    kill -9 $(pidof $1)
    if [[ "$?" == "0" ]]; then
      echo "PID $mypid ($1) killed."
    fi
  else
    echo "None killed."
  fi
  return;
}