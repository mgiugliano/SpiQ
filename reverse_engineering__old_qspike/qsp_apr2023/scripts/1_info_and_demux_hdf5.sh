#!/bin/bash
#
# QSpike Tools 2.0 - 1-INFO-AND-DEMUX-HDF5
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# The script is invoked by the cmd 'source' (i.e. a synonym of built-in shell cmd '.').
# Commands in this script are thus executed in the "current shell context" (i.e. 
# of the calling script) so that env variables set there are also available here.
#
# It processes one *.h5qspike file, whose full path is in $f (e.g. /path/toBic20180920test.h5qspike)

CWD=$(pwd)
NAME=$(basename ${f%.*})   	# Remove the suffix (.mcd)
OUTDIR=$preprocessDir/$NAME # Name an output (sub)folder in preprocessDir
#mkdir -pv $OUTDIR           # Create such a dir, with that name

printf "\nStarting channel extraction..."

# --- EXTRACT/DEMUX INDIVIDUAL CHANNELS ----------------------------------------
#$JULIA/bin/julia --project=Project.toml src/private/channel_extract_hdf5.jl $OUTDIR $f $NAME
$JULIA/bin/julia --project=Project.toml src/private/demultiplex_extract_H5Py.jl $preprocessDir $f

# --- PARSE info.txt ---------------------------------------------------
INFO=(`cat $OUTDIR/${NAME}_info.txt`) # Place the info file into an array (line-by-line)

Trec=${INFO[0]}         	# Duration of the recording [ms], first element
Nsamples=${INFO[1]}			# Number of samples (i.e. Trec * Rate), second element
Rate=${INFO[2]}				# Sampling rate [Hz], third element

# --- EXTRACT EACH STREAM AND DECORATED CHAN NAMES ----------------------------
# The following uses awk, inspired from a Stack Overflow discussion. It works!!
# See the original thread at: https://stackoverflow.com/questions/17988756/how-to-select-lines-between-two-marker-patterns-which-may-occur-multiple-times-w
elec=$(awk '/Nelec/{flag=1;next}/N/{flag=0}flag' $OUTDIR/${NAME}_info.txt)
digi=$(awk '/Ndigi/{flag=1;next}/N/{flag=0}flag' $OUTDIR/${NAME}_info.txt)
anlg=$(awk '/Nanlg/{flag=1;next}/N/{flag=0}flag' $OUTDIR/${NAME}_info.txt)

printf "\nChannel extraction finished!\n"
