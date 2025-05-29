#!/bin/bash

#..source
source ../config.h
source ../software.h

#..rename index
for nn in 0 1 2 3 4 5 6 7 8 9; do
newd=`printf "0%1d" $nn`
mv $nn ${newd}
echo $newd
done

#..store
mkdir dhdl-files
for ii in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16; do
	cp $ii/alch.xvg ./dhdl-files/dhdl_$ii.xvg;
done

#..RUN alchemlyb
../awk/abfe.py ./dhdl-files/
grep -v INFO results.txt | grep -v DEBUG  | grep -v WARN > tmp
mv tmp results.txt

#..clean
mv *.pdf ./dhdl-files
mv *.txt ./dhdl-files
