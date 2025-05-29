#!/bin/bash

#..source
source ../../config.h
source ../../software.h

#..rename index
#for nn in 0 1 2 3 4 5 6 7 8 9; do
#newd=`printf "0%1d" $nn`
#mv $nn ${newd}
#echo $newd
#done

#..store dhdl
mkdir dhdl-files
for ii in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35; do
	cp lambda_$ii/alch.xvg ./dhdl-files/dhdl_$ii.xvg;
done

#..RUN alchemlyb
../../awk/abfe.py ./dhdl-files/
grep -v INFO results.txt | grep -v DEBUG  | grep -v WARN > tmp
mv tmp results.txt

#..clean
mv *.pdf ./dhdl-files
mv *.txt ./dhdl-files
