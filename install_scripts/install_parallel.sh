#!/bin/bash
#
# Automated download, unzip, and install of GNU PARALLEL
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#


# Let's create two folders: "bin" (binaries) and "sw" (software) in $HOME
mkdir -pv $HOME/sw/parallel

# Download GNU Parallel
wget -O parallel.tar.bz2 http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2

# Unzip it and untar it
tar -jxf parallel.tar.bz2

# Delete the archive
rm -f parallel.tar.bz2

# Change name of the untarred folder into nrn_source
cd parallel-2022*

# Configure, compile, install it
./configure --prefix=$HOME/sw/parallel
make
make install

# Configure, compile, install it
cd ..
rm -fr parallel-2022*

# Let's finally create a symbolic link, so that parallel can be easily found
rm -f $HOME/bin/parallel
ln -s $HOME/sw/parallel/bin/parallel $HOME/bin/parallel


# Let's promise we will cite the authors' manuscript in our future papers
#$HOME/bin/parallel --bibtex
touch $HOME/.parallel/will-cite

# Add the path to .bashrc
echo "export PATH=$HOME/bin:$PATH"                         >> ~/.bashrc
echo "export PATH=$HOME/sw/parallel/bin:$PATH"             >> ~/.bashrc
echo "export MANPATH=$MANPATH:$HOME/sw/parallel/share/man" >> ~/.bashrc

# Add the path to the current session
export PATH=$HOME/bin:$PATH
export PATH=$HOME/sw/parallel/bin:$PATH
export MANPATH=$MANPATH:$HOME/sw/parallel/share/man



