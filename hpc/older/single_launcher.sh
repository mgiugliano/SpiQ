#!/bin/bash
#
# QSpike Tools 2.0 - SINGLE-LAUNCHER
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# Launches QSpikeTools in a single computer. First it separates all the
# recordings found in *.h5 files in different *.h5qspike files. Then
# it launches QSpikeTools serially per each *.mcd and *.h5qspike file.
#
# INPUT:
# - dir: path to the data folder, where the input and output folders will be located.

JULIA=(`cat JULIA_PATH.txt`)

shopt -s nullglob # Avoids problems when no h5 or mcd files are found (http://bash.cumulonim.biz/NullGlob.html

# First we need to loop over all the files *.h5, found in "inputDir", and split all the recordings in them into different files
#H5Files=$1/INPUT_FILES/*.h5
#NH5files=$(echo $H5Files | wc -w | tr -d '[:space:]')   # Counting how many *.h5 files there are...

#myCounter=0	
#for f in $H5Files; do   						# For each *.h5 file in inputDir..
#	let "myCounter++" 1						# Increment the counter (it started at 0)
#	echo "Demultiplexing file $f [$myCounter out of $NH5files]" # Print some diagnostic message
#     										# Launch, by "source" (i.e. same env vars)
#											# the actual series of analysis...
#	fileName=$(basename ${f%.*})
#
#	#$JULIA/bin/julia --project=Project.toml src/private/demultiplexH5Py.jl $f
#done

# This is the main loop, over all the files *.mcd, found in "inputDir" 
Files=$1/INPUT_FILES/*.mcd 					# Full-path filenames...
Nfiles=$(echo $Files | wc -w | tr -d '[:space:]')   # Counting how many *.mcd files there are...

echo "Ready to process $Nfiles input *.mcd files..."

myCounter=0									# Simple counter for diagnostic msgs
for f in $Files; do   						# For each *.mcd file in inputDir..
	let "myCounter++" 1						# Increment the counter (it started at 0)
	echo "Analyzing file $f [$myCounter out of $Nfiles]" # Print some diagnostic message
     										# Launch, by "source" (i.e. same env vars)
											# the actual series of analysis...
	fileName=$(basename ${f%.*})
	logDir=$1/OUTPUT_PROCESSED_FILES/$fileName/

	mkdir -pv $logDir

	bash start.sh $1 $f 0
done

# And the same with all the files *.h5qspike, found in "inputDir" 
Files=$1/INPUT_FILES/*.h5 					# Full-path filenames...
Nfiles=$(echo $Files | wc -w | tr -d '[:space:]')   # Counting how many *.mcd files there are...

echo "Ready to process $Nfiles input *.h5 files..."

myCounter=0									# Simple counter for diagnostic msgs
for f in $Files; do   						# For each *.mcd file in inputDir..
	let "myCounter++" 1						# Increment the counter (it started at 0)
	echo "Analyzing file $f [$myCounter out of $Nfiles]" # Print some diagnostic message
     										# Launch, by "source" (i.e. same env vars)
											# the actual series of analysis...
	fileName=$(basename ${f%.*})
	logDir=$1/OUTPUT_PROCESSED_FILES/$fileName/

	mkdir -pv $logDir

	bash start.sh $1 $f 1
done
 
