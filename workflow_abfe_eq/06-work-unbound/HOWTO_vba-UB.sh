#!/bin/bash

#..source
source ../config.h
source ../software.h

#..LOCAL variables
PWD=`pwd`
awkd=../awk
prev=../00-bound

#..RETRIEVE files 
cp ${prev}/cluster/store/file.kappa ./KAPPA
cp ${prev}/cluster/store/file.refs  ./VBA-REFs

#..SEARCH for REFs for r,theta,THETA
awk '(NR==1)' VBA-REFs >> KAPPA
awk '(NR==2)' VBA-REFs >> KAPPA
awk '(NR==4)' VBA-REFs >> KAPPA

#..COMPUTE WORK
echo "sigma_L  ${sigma_L}"  >  SIGMA
echo "sigma_P  ${sigma_P}"  >> SIGMA
echo "sigma_PL ${sigma_PL}" >> SIGMA
awk -f $awkd/work.awk -v IFILE=KAPPA -v IFILE2=SIGMA -v VERBOSE=1

#.CLEAN
rm KAPPA SIGMA 
rm VBA-REFs
