#!/bin/bash
#
# Automated install, unzip, and link Julia 1.7.3
#
# The present script downloads Julia, decompress
# and unzip it into $HOME/sw. Then it removes the
# downloaded archive and adds a symbolic link to
# julia binary executable.
#
# August 3rd 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

# Let's create two folders: "bin" (binaries) and "sw" (software) in $HOME
mkdir -pv $HOME/bin
mkdir -pv $HOME/sw
mkdir -pv $HOME/.julia/config


# Now let's download Julia...
wget --no-check-certificate -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz 

# ..and unpack it in the proper destination folder
mkdir -pv $HOME/sw/julia
tar -xzf julia.tar.gz -C $HOME/sw/julia --strip-components 1
# The last command does in one shot all the following steps (now unecessary):
# gzip -d julia.tar.gz
# tar -xf julia.tar
# mv julia-1.7.2 $HOME/sw/

# Let's clean up, removing the downloaded archive, as it is no longer needed
#rm -f julia.tar.gz

# Let's finally create a symbolic link, so that julia's binary can be easy found
rm -f $HOME/bin/julia
ln -s $HOME/sw/julia/bin/julia $HOME/bin/julia

# Add the path to .bashrc
echo "export PATH=$HOME/bin:$PATH" >> ~/.bashrc

# Add the path to the current session
export PATH=$HOME/bin:$PATH

echo 'ENV["PYTHON"] = "'$HOME'/sw/miniconda3/bin/python3"' >> ~/.julia/config/startup.jl
echo 'println("Setup successful")' >> ~/.julia/config/startup.jl


