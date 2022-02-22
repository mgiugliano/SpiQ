#!/bin/bash
#
# Installation of ALL
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

# local - tar -czf install_scripts.tgz install_scripts
# local - scp install_scripts.tgz mgiuglia@hpc:/home/mgiuglia/

# tar -xzf install_scripts.tgz
# rm install_scripts.tgz
# cd install_scripts/
source install_dotfiles.sh

source install_julia_1.7.sh
source install_parallel.sh
source install_miniconda3.sh
echo "Please log off and on again..."
source install_python_libs.sh
