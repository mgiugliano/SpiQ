#!/bin/bash
#
# QSpike Tools 2.0 - 3-ANALYSIS
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# The script is invoked by the cmd 'source' (i.e. a synonym of built-in shell cmd '.').
# Commands in this script are thus executed in the "current shell context" (i.e. 
# of the calling script) so that env variables set there are also available here.
#
# It calls a Julia serial script that performs the analysis actions over the data from the different 
# channels (found in preprocessDir/NAME/*.jld2 files) and stores the results in analDir/NAME, in the
# form of PDF figures and a .tex report file.

printf "\nStarting analysis...\n"

cd src

$JULIA/bin/julia --project=../Project.toml main_analysis.jl $preprocessDir $analDir $NAME

cd $CWD

printf "Analysis finished! Results can be found in $analDir\n"
