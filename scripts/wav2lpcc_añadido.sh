#!/bin/bash

## \file
## \TODO This file implements a very trivial feature extraction; use it as a template for other front ends.
##\DONE Resuleto para LPCC
## Please, read SPTK documentation and some papers in order to implement more advanced front ends.

# Base name for temporary files
base=/tmp/$(basename $0).$$

# Ensure cleanup of temporary files on exit
trap cleanup EXIT
cleanup() {
   \rm -f $base.*
}

if [[ $# != 3 ]]; then
   echo "$0 lpcc_order input.wav output.lpcc"
   exit 1
fi

lpcc_order=$1
inputfile=$2
outputfile=$3

UBUNTU_SPTK=0
if [[ $UBUNTU_SPTK == 1 ]]; then
   # In case you install SPTK using debian package (apt-get)
   X2X="sptk x2x"
   FRAME="sptk frame"
   WINDOW="sptk window"
   LPC="sptk lpc"
   LPC2C="sptk lpc2c"
else
   # or install SPTK building it from its source
   X2X="x2x"
   FRAME="frame"
   WINDOW="window"
   LPC="lpc"
   LPC2C="lpc2c"
fi

# Main command for feature extration
sox $inputfile -t raw - dither -p 12 | $X2X +sf | $FRAME -l 200 -p 40 | $WINDOW -l 200 -L 200 |
	$LPC2C -l 240 -m $lpcc_order | $LPC2C -m $lpcc_order -M 25  > $base.lpcc
  
# Our array files need a header with the number of cols and rows:
ncol=$((lpcc_order+1)) # lpc p =>  (gain a1 a2 ... ap)
nrow=`$X2X +fa < $base.lpcc | wc -l | perl -ne 'print $_/'$ncol', "\n";'`

# Build fmatrix file by placing nrow and ncol in front, and the data after them
echo $nrow $ncol | $X2X +aI > $outputfile
cat $base.lpcc >> $outputfile

exit