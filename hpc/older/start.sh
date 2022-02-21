#!/bin/bash
#
# QSpike Tools 2.0 - MAIN/ENTRY-POINT SCRIPT
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# Initiates the automated and parallel batch processing of the *.mcd and *.h5qspike files.
#
# INPUT:
# - dir: path to the data folder, where the input and output folders will be located.
# - f: full path and name of the input file.
# - fileType: 0 if the file is an *.mcd, 1 if it is a *.h5qspike

DATADIR=$1
f=$2
fileType=$3

set -euo pipefail
# -e : it causes a bash script to exit immediately when a command fails
# -u : it causes the bash shell to treat unset variables as an error and exit immediately
# -o pipefail : it sets the exit code of a pipeline to that of the rightmost command 
#    to exit with a non-zero status, or to zero if all commands of the pipeline exit successfully.
# -x : causes bash to print each command before executing it

CWD=$(pwd)
JULIA=(`cat JULIA_PATH.txt`)

# --- USER SETTINGS GO HERE --------------------------------------------------
NCORES=(`grep -c ^processor /proc/cpuinfo`)			# Number of cores for GNU parallel and Julia
inputDir=$DATADIR/INPUT_FILES   					# Input folder, containing the *.mcd or *.h5 files
preprocessDir=$DATADIR/OUTPUT_PREPROCESSED_FILES	# Folder containing preprocessed files            
analDir=$DATADIR/OUTPUT_PROCESSED_FILES 			# Folder containing analysis results
codeDir=$CWD/src/private            				# Folder containing the code/executables
#-------------------------------# Preprocessing desired parameters
#FILTERXF=y						# shall I band-p. filter raw data? (n='no',y='yes')
#SAVINGXF=n						# shall I save the xf files?       (n='no',y='yes')
#DETECT_FMIN=400.				# [Hz] Band-pass filter par (high-pass cut-off)
#DETECT_FMAX=3000.				# [Hz] Band-pass filter par (low-pass cut-off)
#STDMIN=5 						# minimum threshold for detection
#STDMAX=10000 					# maximum threshold for detection
#DETECT=both					# type of threshold-events ('neg','pos', or 'both')
#REF=2.5						# [ms] detector dead time
#W_PRE=20 						# no. of pre-event data points stored  (default 20)
#W_POST=44						# no. of post-event data points stored (default 44)
#INTERPOLATION=y 				# interpolation with cubic splines (n='no',y='yes')
#INT_FACTOR=2 					# interpolation factor
#-----------------------------------------------------------------------------
INFOCMD=$codeDir/get_info        			# Full path command for 'get_info'
EXTRCMD=$codeDir/channel_extract 			# Full path command for 'channel_extract'
export DYLD_LIBRARY_PATH=$CWD/src/private 	# This should avoid "lib not found"
#-----------------------------------------------------------------------------

echo $DATADIR
echo $f

echo -e "\n\e[42mSTART\e[49m\n"

if [ "$fileType" -eq "0" ]; then
	source ./scripts/1_info_and_demux_mcd.sh 	# Extracts information (.mcd) and demultiplex individual channels (.dat)
elif [ "$fileType" -eq "1" ]; then
	source ./scripts/1_info_and_demux_hdf5.sh 	# Extracts information (.h5qspike) and demultiplex individual channels (.dat)
fi
source ./scripts/2_preprocessing.sh 	# Preprocesses the data on each channel (.dat) and stores it in separate files (.jld2)
source ./scripts/3_analysis.sh 			# Analyses the preprocessed data from all channels (.jld2) together and writes a report with the results (.tex)

echo -e "\n\e[41mEND\e[49m\n- Time $SECONDS s\n"