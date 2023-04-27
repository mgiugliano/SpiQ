#!/bin/bash
#
# Installation of dot files
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

rm -rf $HOME/.bash*

mkdir -p $HOME/.tmp
mkdir -p $HOME/.vim
mkdir -p $HOME/.bashrc.d

cp dotfiles/.bashrc.d/*.bash $HOME/.bashrc.d/

cp dotfiles/.bash_profile $HOME/
cp dotfiles/.bashrc $HOME/
cp dotfiles/.mymotd.sh $HOME/
cp dotfiles/.cheat_sheet $HOME/
cp dotfiles/.vimrc $HOME/
cp dotfiles/.nanorc $HOME/



