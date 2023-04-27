#!/usr/bin/env bash
#
# Transfer files FROM NASGiugliano to your current host
#
# AUTHOR
# Michele Giugliano - mgiugliano@gmail.com
#
# This script, when launched, copies (recursively) all files from a specified
# subfolder on NASGiugliano to a spcified folded on the current host.
#
# Remember to: chmod +x transfer_FROM_nas.sh


# ---- EDIT ONLY THE VARIABLES 'FROM' AND 'TO' BELOW


# e.g. FROM=/data/MEAdata/mgiuglia/*    (note the final slash and asterisk)
#FROM=data/MEAdata/mgiuglia/*
FROM=data/MEAdata/Torre_collab/h5_and_analysed_files/U87_exosomes_DIV9-12_PATCH-CLAMP_LIKE/h5/2021-03-19T09-55-1938280_control_before_2.h5
# e.g. TO=/home/mgiuglia
#TO=/home/mgiuglia/tmp
TO=/home/mgiuglia



# ---- DO NOT EDIT BELOW THIS LINE --------------------------------

HOST=nasgiugliano.nb.sissa.it
USER=sshd
ABSPATH=/mnt/HD/HD_a2/$FROM
#CWD=$(pwd)

echo ""
echo "File transfer ***from*** NASGiugliano"
echo ""
echo "Source directory is set to: $ABSPATH"
echo "Target directory is set to: $TO"
echo "Ready to download ALL files/subfolders from the source to the target..."
echo
read -p "Continue (y/n)?" choice
case "$choice" in
  y|Y ) scp -r -c aes128-gcm@openssh.com $USER@$HOST:$ABSPATH $TO;;
#  y|Y ) scp -r -C $USER@$HOST:$ABSPATH $TO;;
#  y|Y ) echo "yes";;
#  n|N ) echo "Download aborted!";;
  * ) echo "Download aborted!";;
esac

echo ""

