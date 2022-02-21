# .bashrc

# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)

export OS="`uname`"

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Load supplementary scripts --------------------------------------------------
if [ -e $HOME/.bashrc.d/variables.bash ]; then    # If it exists..
    source $HOME/.bashrc.d/variables.bash         # variables
fi
#------------------------------------------------------------------------------
if [ -e $HOME/.bashrc.d/prompt.bash ]; then       # If it exists..
    source $HOME/.bashrc.d/prompt.bash       	  # prompt
fi
#------------------------------------------------------------------------------
if [ -e $HOME/.bashrc.d/utils.bash ]; then        # If it exists..
    source $HOME/.bashrc.d/utils.bash       	  # utils
fi
#------------------------------------------------------------------------------
if [ -e $HOME/.bashrc.d/aliases.bash ]; then      # If it exists..
    source $HOME/.bashrc.d/aliases.bash           # aliases (*after* utils)
fi
#------------------------------------------------------------------------------
if [ -e $HOME/.mymotd.sh ]; then                  # If it exists..
    source $HOME/.mymotd.sh                       # Load the message of the Day
fi
#-------------------------------------------------------------------------------








