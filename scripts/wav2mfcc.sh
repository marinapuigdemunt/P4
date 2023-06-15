#!/bin/bash

# Make pipeline return code the last non-zero one or zero if all the commands return zero.
set -o pipefail

## \file
## \TODO This file implements a very trivial feature extraction; use it as a template for other front ends.
##\DONE Resuleto para MFCC

## Please, read SPTK documentation and some papers in order to implement more advanced front ends.

# Base name for temporary files
base=/tmp/$(basename $0).$$

# Ensure cleanup of temporary files on exit
trap cleanup EXIT
cleanup() {
   \rm -f $base.*
}

if [[ $# != 4 ]]; then
   echo "$0 mfcc_order mfcc_order_channel_melfilterbank input.wav output.mfcc"
   exit 1
fi

mfcc_order=$1
mfcc_order_channel_melfilterbank=$2
inputfile=$3
outputfile=$4

if [[ $UBUNTU_SPTK == 1 ]]; then
   # In case you install SPTK using debian package (apt-get)
   X2X="sptk x2x"
   FRAME="sptk frame"
   WINDOW="sptk window"
   MFCC="sptk mfcc"
else
   # or install SPTK building it from its source
   X2X="x2x"
   FRAME="frame"
   WINDOW="window"
   MFCC="mfcc"
fi

# Main command for feature extration
   sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 200 -p 40 |
    $MFCC -l 200 -m $mfcc_order -n $mfcc_order_channel_melfilterbank -s 8 -w 0 > $base.mfcc

# Our array files need a header with the number of cols and rows:
ncol=$((mfcc_order)) # mfcc p =>  (c0 c1 c2 ... cp-1)
nrow=`$X2X +fa < $base.mfcc | wc -l | perl -ne 'print $_/'$ncol', "\n";'`
#nrow=$(wc -c $base.mfcc | cut -d ' ' -f1 | perl -ne 'print $_/'$ncol'/4, "\n";')
if [[ $? != 0 ]]; then
   exit 1
fi

# Build fmatrix file by placing nrow and ncol in front, and the data after them
echo $nrow $ncol | $X2X +aI > $outputfile
cat $base.mfcc >> $outputfile

exit