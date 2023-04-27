#
# Automated install, unzip, and link SpiQ
#
#
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
#

# Let's create two folders: "bin" (binaries) and "sw" (software)
# They are created in the $HOME folder of the user
mkdir -pv $HOME/bin
mkdir -pv $HOME/sw

# Now let's change dir into "sw" and download and unpack SpiQ
cd $HOME/sw
#wget --no-check-certificate https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz
#gzip -d ./julia-1.7.2-linux-x86_64.tar.gz
#tar -xf ./julia-1.7.2-linux-x86_64.tar

# Let's clear up, removing the downloaded archive, as it is no longer needed
#rm -f ./julia-1.7.2-linux-x86_64.tar

# Let's finally create a symbolic link, so that julia's binary can be easy found
#ln -s ./julia-1.7.2/bin/julia $HOME/bin/julia

cd $HOME

