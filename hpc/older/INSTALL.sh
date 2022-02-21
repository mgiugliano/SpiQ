#!/bin/bash
#
# QSpike Tools 2.0 - INSTALL
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# Install all the dependencies necessary to use QSpikeTools in a separated Julia environment.
# More information on these dependencies can be found in doc/documentation.md


# Writes the path to the Julia installation into a file
# This will be used by QSpikeTools to find Julia later
# Default is $HOME/julia-1.3.0, change it if necessary
JULIA=$HOME/julia-1.3.0
echo "Assuming Julia to be installed in $JULIA"
echo -n "$JULIA" > JULIA_PATH.txt

echo "Installing QSpikeTools dependencies..."
$JULIA/bin/julia --project=Project.toml src/private/install_dependencies.jl
echo "Finished!"