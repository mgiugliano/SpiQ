#!/bin/bash
#
# Install Python3 libraries + Neuron (after MiniConda3 )
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

if [ -e $HOME/sw/miniconda3/conda ]; then      # If it exists..

    source $HOME/.bashrc.d/aliases.bash          
    conda install numpy scipy matplotlib
    conda install -c conda-forge neuron

    rm -f $HOME/bin/nrnivmodl
    ln -s $HOME/sw/miniconda3/bin/nrnivmodl $HOME/bin/nrnivmodl

else                                           # If it doesn't exist..
    echo "ERROR: Miniconda3 has NOT been installed locally."
    echo "Unable to continue."
fi




