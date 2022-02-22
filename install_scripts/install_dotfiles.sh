#!/bin/bash
#
# Installation of dot files
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

rm -rf $HOME/.bash*

mkdir $HOME/.tmp
mkdir $HOME/.vim
mkdir $HOME/.bashrc.d

cp .dotfiles/.bashrc.d/*.bash $HOME/.bashrc.d/
cp .bash* $HOME/
cp .mymotd.sh $HOME/
cp .cheat_sheet $HOME/
cp .vimrc $HOME/



