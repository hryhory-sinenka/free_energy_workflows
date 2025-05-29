#!/bin/bash

#..SOURCE
source ../config.h
source ../software.h

#..FILES
prev=${BND_MD}

#..retrieve FILES
cp ${prev}/topol.top ./
cp ${prev}/index.ndx ./
cp ${prev}/BoreschRestraint.top restraints.itp

echo '#include "restraints.itp"' >> topol.top

#cp ${prev}/step4.0_minimization.gro ./
cp -rp ${prev}/toppar ./
ln -s ${prev}/step5_production.cpt ./prod.cpt
ln -s ${prev}/step5_production.gro ./prod.gro
ln -s ${prev}/step5_production.tpr ./prod.tpr

#..RE_CENTER traj
#$gmx trjcat -f ${prev}/step5_*.xtc -o file.xtc -cat
#echo "Protein SYSTEM" |\
#$gmx trjconv -f file.xtc -s prod.tpr -n index.ndx -o noPBC.xtc -pbc mol -ur compact -center

#..EXTRACT minimized complex
#igro=${prev}/step4.0_minimization.gro
#itpr=${prev}/step4.0_minimization.tpr
#echo "SOLU SOLU" |\
#$gmx trjconv -f ${igro} -s ${itpr} -n index.ndx -o complex_min.pdb -pbc mol -ur compact -center

#..CLEAN
#rm \#*
#rm file.xtc
#rm TMP
#exit
