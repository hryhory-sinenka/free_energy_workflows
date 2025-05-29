#!/bin/bash


#pmx stage to finally prepare hybrid topologies. The first command maps atoms of one ligand into the other, while the second command creates actual hybrid topologies which will later be used for each frame to generate hybrid geometry.

ligand_0=BENZ
state=water_test
s0=benzene
s1=toluene

# We generate the hybrid topologies, which will be used for all the frames

pmx atomMapping -i1 $state/$s0/pmx/$s0.pdb -i2 $state/$s1/pmx/$s1.pdb -o1 $state/$s0-$s1/pmx/pairs_to_be_used.dat -o2 $state/$s0-$s1/pmx/pairs2.dat -opdb1 $state/$s0-$s1/pmx/out_pdb1.pdb -opdb2 $state/$s0-$s1/pmx/out_pdb2.pdb -opdbm1 $state/$s0-$s1/pmx/out_pdb_morphe1.pdb -opdbm2 $state/$s0-$s1/pmx/out_pdb_morphe2.pdb

pmx ligandHybrid -i1 $state/$s0/pmx/$s0.pdb -i2 $state/$s1/pmx/$s1.pdb -itp1 $state/$s0/pmx/ffmol.itp -itp2 $state/$s1/pmx/ffmol.itp -pairs $state/$s0-$s1/pmx/pairs_to_be_used.dat -oA $state/$s0-$s1/pmx/mergedA.pdb -oB $state/$s0-$s1/pmx/mergedB.pdb -oitp $state/$s0-$s1/pmx/MOL_to_be_used.itp -offitp $state/$s0-$s1/pmx/ffmerged_to_be_used.itp --scDUMd 0.1

#We merge the dummy atomtypes with the files containing all the other atomtypes.

tail -n +2 $state/$s0-$s1/pmx/ffmerged_to_be_used.itp >> ${state}/${s0}/pmx/parameters.itp

#Here, we return the positional restraints on the non-alchemical part of the hybrid topology. The situation with restraints may be modified later, as current restraints are suboptimal.
cp Water/${s0}_water/gromacs/toppar/${ligand_0}.itp ${state}/${s0}/pmx/MOL_posres.itp

line_number=$(grep -n "#ifdef POSRES" "${state}/${s0}/pmx/MOL_posres.itp" | cut -d: -f1)

sed -n "${line_number},\$p" "${state}/${s0}/pmx/MOL_posres.itp" | sed '/./!d' >> "${state}/${s0}-${s1}/pmx/MOL_to_be_used.itp"


#####
#Analogous code, but starting from toluene
#####


ligand_0=TOLU
state=water_test
s0=toluene
s1=benzene


pmx atomMapping -i1 $state/$s0/pmx/$s0.pdb -i2 $state/$s1/pmx/$s1.pdb -o1 $state/$s0-$s1/pmx/pairs_to_be_used.dat -o2 $state/$s0-$s1/pmx/pairs2.dat -opdb1 $state/$s0-$s1/pmx/out_pdb1.pdb -opdb2 $state/$s0-$s1/pmx/out_pdb2.pdb -opdbm1 $state/$s0-$s1/pmx/out_pdb_morphe1.pdb -opdbm2 $state/$s0-$s1/pmx/out_pdb_morphe2.pdb

pmx ligandHybrid -i1 $state/$s0/pmx/$s0.pdb -i2 $state/$s1/pmx/$s1.pdb -itp1 $state/$s0/pmx/ffmol.itp -itp2 $state/$s1/pmx/ffmol.itp -pairs $state/$s0-$s1/pmx/pairs_to_be_used.dat -oA $state/$s0-$s1/pmx/mergedA.pdb -oB $state/$s0-$s1/pmx/mergedB.pdb -oitp $state/$s0-$s1/pmx/MOL_to_be_used.itp -offitp $state/$s0-$s1/pmx/ffmerged_to_be_used.itp --scDUMd 0.1

tail -n +2 $state/$s0-$s1/pmx/ffmerged_to_be_used.itp >> ${state}/${s0}/pmx/parameters.itp

cp Water/${s0}_water/gromacs/toppar/${ligand_0}.itp ${state}/${s0}/pmx/MOL_posres.itp

line_number=$(grep -n "#ifdef POSRES" "${state}/${s0}/pmx/MOL_posres.itp" | cut -d: -f1)

sed -n "${line_number},\$p" "${state}/${s0}/pmx/MOL_posres.itp" | sed '/./!d' >> "${state}/${s0}-${s1}/pmx/MOL_to_be_used.itp"

