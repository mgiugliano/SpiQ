#!/bin/bash
#
# QSpike Tools 2.0 - 1-INFO-AND-DEMUX-MCD
# 
# AUTHORS:
# Michele Giugliano - mgiugliano@gmail.com
# Rodrigo Amaducci - amaducci.rodrigo@gmail.com
#

# The script is invoked by the cmd 'source' (i.e. a synonym of built-in shell cmd '.').
# Commands in this script are thus executed in the "current shell context" (i.e. 
# of the calling script) so that env variables set there are also available here.
#
# It processes one *.mcd file, whose full path is in $f (e.g. /path/toBic20180920test.mcd)

CWD=$(pwd)
NAME=$(basename ${f%.*})   	# Remove the suffix (.mcd)
OUTDIR=$preprocessDir/$NAME # Name an output (sub)folder in preprocessDir
mkdir -pv $OUTDIR           # Create such a dir, with that name

# --- EXTRACT INFORMATION -----------------------------------------------------
$INFOCMD $f 				# The get_info command is invoked here, producing
							# the output file 'information.txt'...
# --- PARSE information.txt ---------------------------------------------------
INFO=(`cat information.txt`) # Place the info file into an array (line-by-line)

Trec=${INFO[0]}         	# Duration of the recording [s], first element
Nsamples=${INFO[1]}			# Number of samples (i.e. Trec * Rate), second element
Rate=${INFO[2]}				# Sampling rate [Hz], third element

# --- EXTRACT EACH STREAM AND DECORATED CHAN NAMES ----------------------------
# The following uses awk, inspired from a Stack Overflow discussion. It works!!
# See the original thread at: https://stackoverflow.com/questions/17988756/how-to-select-lines-between-two-marker-patterns-which-may-occur-multiple-times-w
elec=$(awk '/Nelec/{flag=1;next}/N/{flag=0}flag' information.txt)
digi=$(awk '/Ndigi/{flag=1;next}/N/{flag=0}flag' information.txt)
anlg=$(awk '/Nanlg/{flag=1;next}/N/{flag=0}flag' information.txt)
# -----------------------------------------------------------------------------
mv information.txt $OUTDIR/${NAME}_info.txt  # Store information.txt into analDir

# --- EXTRACT/DEMUX INDIVIDUAL CHANNELS ----------------------------------------
# We do so taking advantage of GNU Parallel for distributing jobs. The simplest
# way is to first create a (temporary) text file, containing the list of (sub)jobs.

JOBLIST_FNAME=$(mktemp /tmp/QSpike-joblist.XXXXXX) 	# Create a temporary file

# Header of the temporary file
echo "# QSpike 2.0 - Job List, generated on $(date)" >> $JOBLIST_FNAME
echo "# <EXTRACT/DEMUX INDIVIDUAL CHANNELS> step" >> $JOBLIST_FNAME
echo "# USE: parallel --jobs $NCORES < $JOBLIST_FNAME" >> $JOBLIST_FNAME # !! changed the 8 to NCORES

# We now go through each line of the arrays 'elec', 'anlg', 'digi' and
# use their content (as well as their absolute number) to generate the
# 'channel-extract' shell commands, properly invoked...
#
# Each individual channel file will be saved into the output subfolder, 
# with its file name carrying information on the corresponding decorated name.

undec=0                # Counter over the (hardware/undecorated) chan names
for chan in $elec; do
	echo "$EXTRCMD elec $undec $f $OUTDIR/"$NAME"_elec_$chan.dat" >> $JOBLIST_FNAME
	let "undec++" 1
done
# ------------
undec=0                # Counter over the (hardware/undecorated) chan names
for chan in $anlg; do
	echo "$EXTRCMD anlg $undec $f $OUTDIR/"$NAME"_anlg_$chan.dat" >> $JOBLIST_FNAME 
	let "undec++" 1
done
# ------------
undec=0                # Counter over the (hardware/undecorated) chan names
for chan in $digi; do
	echo "$EXTRCMD digi $undec $f $OUTDIR/"$NAME"_digi_$chan.dat" >> $JOBLIST_FNAME
	let "undec++" 1
done
# ------------

cd $codeDir				                  # Change dir into the code dir (for the dylib?)

printf "\nStarting channel extraction..."
# Check if parallel is installed or not
if hash parallel 2>/dev/null; then
	printf " Using GNU parallel\n"
    parallel --jobs $NCORES < $JOBLIST_FNAME 	# Execute the joblist by GNU Parallel
else
	printf " In serial\n"
	source $JOBLIST_FNAME     			  		# Execute the joblist in serial
fi
printf "\nChannel extraction finished!\n"

cd $CWD									  # Change dir back to $CWD
#rm $JOBLIST_FNAME						  # The temporary file is deleted
# -----------------------------------------------------------------------------
