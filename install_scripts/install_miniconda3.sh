#!/bin/bash
#
# Install MiniConda3 (Python3 minimal distrib)
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

# Let's create two folders: "bin" (binaries) and "sw" (software) in $HOME
mkdir -pv $HOME/bin
mkdir -pv $HOME/sw/miniconda3

# Now let's download and unpack miniconda
wget --no-check-certificate -O miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# We make the install script executable and run it
bash ./miniconda3.sh -f -b -p $HOME/sw/miniconda3
rm -f ./miniconda3.sh

# We activate the installation
eval "$($HOME/sw/miniconda3/bin/conda shell.bash hook)"
$HOME/sw/miniconda3/bin/conda init

rm -f $HOME/bin/conda
ln -s $HOME/sw/miniconda3/bin/conda $HOME/bin/conda

rm -f $HOME/bin/python3
ln -s $HOME/sw/miniconda3/bin/python3 $HOME/bin/python3

echo ""
echo ""
echo "Miniconda3 has been installed locally!"
echo "Restart the shell by logging out and then logging back in."
echo ""
echo "Consider **later** launching the installer for Python3 libraries (and Neuron)."
echo ""
echo ""
echo ""
echo ""
