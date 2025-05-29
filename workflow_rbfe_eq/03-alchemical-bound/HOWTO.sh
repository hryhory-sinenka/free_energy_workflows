#!/bin/bash

#..source
#source ../config.h
#source ../software.h

#..LOCAL variables
PWD=`pwd`
srdir=$PWD/SRC
prev=../R1/Complex

#..RETRIEVE files 
TMPD=./tmp
if [ ! -d $TMPD ]; then mkdir $TMPD; fi
cp ${prev}/NPT0.gro $TMPD/init.gro
cp ${prev}/NPT0.cpt $TMPD/init.cpt
cp ${prev}/index.ndx ./$TMPD
cp ${prev}/topol.top ./$TMPD
cp -r ${prev}/toppar ./$TMPD
#exit

#..LOOP over lambda
for ll in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
wkdir=lambda_$ll
mkdir $wkdir
cp -r $TMPD/*   $wkdir/ 
echo $wkdir >> SUMM

#..RUN Gromacs
cd $wkdir/
cat $srdir/PROD.tmpl | \
sed s/YYYYY/$ll/g > PROD.mdp
#
gmx_mpi grompp -f PROD.mdp -c init.gro -t init.cpt -p topol.top -o alch.tpr -maxwarn 1

#gmx_mpi mdrun -deffnm alch -plumed vba.dat -v

mpirun -np 1 gmx_mpi mdrun -deffnm alch -v -ntomp 14 -pin on -pinoffset 0

#..recenter trj
echo -e "1 0" | gmx_mpi trjconv -f alch.xtc -s alch.tpr -n index.ndx -o file.xtc -pbc mol -ur compact -center
mv file.xtc alch.xtc


#..store (checkpoint)
cp alch.cpt ../tmp/init.cpt
cp alch.gro ../tmp/init.gro

#..iterate
cd ../
done

#..clean
rm -rf $TMPD
rm \#* bck.*
exit
