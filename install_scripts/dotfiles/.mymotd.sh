#!/usr/bin/env bash

# My Message-of-the-Day!

bold=$(tput bold)
normal=$(tput sgr0)

echo ""
echo "Connected to: ${bold}$(uname -n)${normal} (node) -- ${bold}$(uname -o)${normal}  $(uname -m)"
echo "Stats:        ${bold}$(uptime)${normal}"
echo ""
echo "You are:      ${bold}${USER}${normal}"
echo "Home is:      ${bold}${HOME}${normal}"
echo "Shell is:     ${bold}${SHELL}${normal} (v. $BASH_VERSION)"
if command -v quota &> /dev/null
then
  echo "Quota is:${bold}$(quota | head -n 1)${normal}"
  echo "         ${bold}$(quota | tail -n 1)${normal}"
fi
echo ""
if command -v curl &> /dev/null
then
echo "${bold}Trieste:${normal} $(curl -s wttr.in/Trieste?format=%t+%c)"
echo ""
fi
echo "Type: ${bold}cs${normal} to print a cheat-sheet of commands and aliases."
echo ""
echo ""
