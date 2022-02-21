#!/bin/bash
#
# Installation of dot files
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

mkdir $HOME/.tmp
mkdir $HOME/.vim

rm -rf $HOME/.bash*

cp -r ./dotfiles/.* $HOME/


