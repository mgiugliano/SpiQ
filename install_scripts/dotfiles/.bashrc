# .bashrc

# only called for non-interactive logins (e.g. SCP sessions)

# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)

export OS="`uname`"

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi