#!/bin/bash

#..SOURCE
source ../config_water.h
source ../software.h

#..FILES
prev=${UNB_MD}

#..retrieve FILES
cp ${prev}/topol.top topol.top
cp ${prev}/index.ndx ./
cp -rp ${prev}/toppar ./
ln -s ${prev}/step5_production.cpt ./prod.cpt
ln -s ${prev}/step5_production.gro ./prod.gro
ln -s ${prev}/step5_production.tpr ./prod.tpr

#..RE_CENTER traj
#$gmx trjcat -f ${prev}/step5_*.xtc -o file.xtc -cat
#echo "${GUEST} System" |\
#$gmx trjconv -f file.xtc -s prod.tpr -n index.ndx -o noPBC.xtc -pbc mol -ur compact -center

#..CLEAN
