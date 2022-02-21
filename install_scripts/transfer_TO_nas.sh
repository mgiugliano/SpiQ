#!/usr/bin/env bash
#
# Transfer files to NASGiugliano from your current host
#
# AUTHOR
# Michele Giugliano - mgiugliano@gmail.com
#
# This script, when launched, copies (recursively) all files from a specified
# subfolder to NASGiugliano.
#
# Remember to: chmod +x transfer_to_nas.sh


# ---- EDIT ONLY THE VARIABLES 'FROM' AND 'TO' BELOW

# e.g. FROM=/home/mgiuglia/tmptmp/* 	(note the final slash and asterisk)
FROM=/home/mgiuglia/tmp/*


# e.g. TO=/data/MEAdata/mgiuglia/    (note the final slash)
TO=data/MEAdata/mgiuglia/



# ---- DO NOT EDIT BELOW THIS LINE --------------------------------

HOST=nasgiugliano.nb.sissa.it
USER=sshd
ABSPATH=/mnt/HD/HD_a2/$TO
#CWD=$(pwd)

echo ""
echo "File transfer ***to*** NASGiugliano"
echo ""
echo "Source directory is set to: $FROM"
echo "Target directory is set to: $ABSPATH"
echo "Ready to upload ALL files/subfolders from the source to the target..."
echo
read -p "Continue (y/n)?" choice
case "$choice" in
  y|Y ) scp -r -C $FROM $USER@$HOST:$ABSPATH;;
#  y|Y ) echo "yes";;
#  n|N ) echo "Download aborted!";;
  * ) echo "Download aborted!";;
esac

echo ""
