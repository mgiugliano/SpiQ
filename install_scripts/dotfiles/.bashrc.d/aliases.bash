# aliases.bash

# For a full list of active aliases, run `alias`

# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)

alias cs="source $HOME/.cheat_sheet"

# Slurm useful aliases
alias mysqueue="squeue -l -u ${USER} | less"

# List all files colorized in long format
alias ls="ls -GFhp --color=auto"
alias lls="ls -lGFhp --color=auto"
alias l="ls -lGFhp --color=auto"
alias la="ls -GAFhp --color=auto"
alias lsd='ls -lG --color=auto | grep "^d"'

# Grep puts in bold the searched string
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# History and background jobs
alias h='history'
alias j='jobs -l'

# Easier navigation: .., ...,
cd() { builtin cd "$@"; ls; }   # Always list directory contents upon 'cd'
alias cd..="cd .."

# mv, rm, cp
alias rm='rm -iv'                           # Preferred 'rm' implementation
alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation
alias wget='wget -c'                        # Preferred 'wget' implementation (resume download)

alias ungzip="gunzip -k"
alias which='type -all'                     # which:        Find executables
alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths

# Disc utils and File size
alias df="df -H"
alias du="du -sh"
alias fs="stat -f \"%z bytes\""
alias numfiles='echo $(ls -1 | wc -l)' # numFiles: Count non-hidden files in ./

# Shortcuts
alias vi='vim'
alias x='exit'
alias clc="clear"
alias c='clear'                        # c:            Clear terminal display
alias ~="cd ~"                         # ~:            Go Home

