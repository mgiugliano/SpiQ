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
echo "Your PWD is:  ${bold}${PWD}${normal}"
echo ""
echo "${bold}Trieste:${normal} $(curl -s wttr.in/Trieste?format=%t+%c)"
echo ""
echo "Type: ${bold}cs${normal} to print a cheat-sheet of commands and aliases."
echo ""
echo ""
