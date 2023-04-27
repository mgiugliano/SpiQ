#!/bin/bash
#
# QSpike Tools 2.0 - 2-PREPROCESSING
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# The script is invoked by the cmd 'source' (i.e. a synonym of built-in shell cmd '.').
# Commands in this script are thus executed in the "current shell context" (i.e. 
# of the calling script) so that env variables set there are also available here.
#
# It calls a Julia parallel script that performs the preprocessing actions over the data from the different 
# channels (found in preprocessDir/NAME/*.dat files) and stores the results in *.jld2 files (in the same path).


# Number of files of each type of recording (counts the number of decorated names)
Nelec=$(echo -n "$elec" | wc -w)
Ndigi=$(echo -n "$digi" | wc -w)
Nanlg=$(echo -n "$anlg" | wc -w)

printf "\nStarting preprocessing...\n"

cd src

$JULIA/bin/julia --project=../Project.toml main_preprocess.jl $preprocessDir $NAME $Nsamples $Rate $Nelec $elec $Ndigi $digi $Nanlg $anlg

cd $CWD

printf "Preprocessing finished!\n"