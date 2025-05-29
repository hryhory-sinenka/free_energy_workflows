#!/bin/bash

#This script extracts the frames from the trajectories and for each frame builds hybrid geometry instead of non-hybrid one. This is the last script before running GROMACS nonequilibrium calculations. 

state=water_test
s0=benzene
s1=toluene
ligand_0=BENZ
ligand_1=TOLU

#Exctract frames
echo "2 0 \n" | gmx_mpi trjconv -f $state/$s0/step5_production.trr -s $state/$s0/step5_production.tpr -b 10400 -skip 4 -sep  -pbc mol -ur compact -center -o $state/$s0-$s1/frame.gro

#Delete backup files
rm $state/$s0-$s1/*#*
rm $state/$s0-$s1/pmx/*#*

#Rename all ligand entries with resname MOL

cd $state/$s0-$s1/
for file in *frame*.gro; do
  if [ -f "$file" ]; then
    sed -i "s/${ligand_0}/MOL/g" "$file"
  fi
done
cd ../../


#Some games with reformatting to make GROMACS and pmx work with files correctly, and finally the generation the ligand with hybrid geometry
# Be sure to note that we do not need to use the generated hybrid topologies - we have already generated the ones which will be used for each frame on the previous steps

gmx_mpi editconf -f $state/$s0-$s1/frame0.gro -o $state/$s0-$s1/frame0.pdb

cat $state/$s0-$s1/frame0.pdb | grep MOL > $state/$s0-$s1/pmx/tmp.pdb

gmx_mpi editconf -f $state/$s0-$s1/pmx/tmp.pdb -o $state/$s0-$s1/pmx/tmp.pdb

pmx ligandHybrid -i1 $state/$s0-$s1/pmx/tmp.pdb -i2 $state/$s1/pmx/$s1.pdb -itp1 $state/$s0/pmx/ffmol.itp -itp2 $state/$s1/pmx/ffmol.itp -pairs $state/$s0-$s1/pmx/pairs_to_be_used.dat -oA $state/$s0-$s1/pmx/mergedA.pdb -oB $state/$s0-$s1/pmx/mergedB.pdb -oitp $state/$s0-$s1/pmx/MOL.itp -offitp $state/$s0-$s1/pmx/ffmerged.itp --scDUMd 0.1

# Calculate the difference in the number of rows containing "MOL" between the two files

gmx_mpi editconf -f $state/$s0-$s1/pmx/mergedA.pdb -o $state/$s0-$s1/pmx/mergedA.gro

diff=$(($(grep -c "MOL" $state/$s0-$s1/pmx/mergedA.gro) - $(grep -c "MOL" $state/$s0-$s1/frame0.gro)))

# Update the second row in frame0.gro by adding the calculated difference
current_value=$(sed -n '2p' $state/$s0-$s1/frame0.gro)
new_value=$((current_value + diff))

# Update the second row with the new value
sed -i "2s/$current_value/$new_value/" $state/$s0-$s1/frame0.gro


# Appending generated dummy atoms to the frame where velocities for non-dummy atoms are present

sed -i '1,2d; $d' "$state/$s0-$s1/pmx/mergedA.gro"

grep '.*MOL.*' $state/$s0-$s1/pmx/mergedA.gro > output.tmp && mv output.tmp $state/$s0-$s1/pmx/mergedA.gro

cp $state/$s0-$s1/frame0.gro $state/$s0-$s1/frame0_bck.gro
cp $state/$s0-$s1/frame0.gro $state/$s0-$s1/frame0_change.gro
rm $state/$s0-$s1/frame0.gro



file1="$state/$s0-$s1/frame0_change.gro"
file2="$state/$s0-$s1/pmx/mergedA.gro"
output_file="$state/$s0-$s1/frame0.gro"

# Find the number of lines containing "MOL" in file1
num_lines_file1=$(grep -c 'MOL' "$file1")

# Extract additional lines containing "MOL" from file2 starting from the (num_lines_file1 + 1)-th line
#additional_lines=$(awk 'NR > n && /MOL/{print}' n="$num_lines_file1" "$file2")

additional_lines=$(grep 'MOL' "$file2" | tail -n +$((num_lines_file1 + 1)))

# Append additional lines to file1
awk '1; /MOL/ && ++n == m {print additional}' m="$num_lines_file1" additional="$additional_lines" "$file1" > "$output_file"


#The command below depends on the system you're exploring. E.g., sometimes you need membrane to have as a group in your index.ndx file and so on. 


printf "2\n name 6 SOLU\n 3 | 4 | 5\n name 7 SOLV\n 0 & ! a D* & ! a HV*\n name 8 System_&_!D*_&_!HV*\n q\n" | gmx_mpi make_ndx -f $state/$s0-$s1/frame0.gro -o $state/$s0-$s1/index.ndx

rm $state/$s0-$s1/frame0_change.gro

#####
#Now, we start iterations over remaining frames 
#####

for i in {1..99}; do
   rm $state/$s0-$s1/*#*
   rm $state/$s0-$s1/pmx/*#*
   gmx_mpi editconf -f $state/$s0-$s1/frame${i}.gro -o $state/$s0-$s1/frame${i}.pdb

   cat $state/$s0-$s1/frame${i}.pdb | grep MOL > $state/$s0-$s1/pmx/tmp.pdb

   gmx_mpi editconf -f $state/$s0-$s1/pmx/tmp.pdb -o $state/$s0-$s1/pmx/tmp.pdb

   pmx ligandHybrid -i1 $state/$s0-$s1/pmx/tmp.pdb -i2 $state/$s1/pmx/$s1.pdb -itp1 $state/$s0/pmx/ffmol.itp -itp2 $state/$s1/pmx/ffmol.itp -pairs $state/$s0-$s1/pmx/pairs_to_be_used.dat -oA $state/$s0-$s1/pmx/mergedA.pdb -oB $state/$s0-$s1/pmx/mergedB.pdb -oitp $state/$s0-$s1/pmx/MOL.itp -offitp $state/$s0-$s1/pmx/ffmerged.itp --scDUMd 0.1

   gmx_mpi editconf -f $state/$s0-$s1/pmx/mergedA.pdb -o $state/$s0-$s1/pmx/mergedA.gro

   cp $state/$s0-$s1/pmx/mergedA.gro $state/$s0-$s1/pmx/mergedA_bck${i}.gro

   sed -i "2s/$current_value/$new_value/" $state/$s0-$s1/frame${i}.gro

   grep '.*MOL.*' $state/$s0-$s1/pmx/mergedA.gro > output.tmp && mv output.tmp $state/$s0-$s1/pmx/mergedA.gro

   cp $state/$s0-$s1/frame${i}.gro $state/$s0-$s1/frame${i}_bck.gro
   cp $state/$s0-$s1/frame${i}.gro $state/$s0-$s1/frame${i}_change.gro
   rm $state/$s0-$s1/frame${i}.gro

# Find the number of lines containing "MOL" in file1
   num_lines_file1=$(grep -c 'MOL' "$state/$s0-$s1/frame${i}_change.gro")

# Extract additional lines containing "MOL" from file2 starting from the (num_lines_file1 + 1)-th line
   additional_lines=$(awk 'NR > n && /MOL/{print}' n="$num_lines_file1" "$state/$s0-$s1/pmx/mergedA.gro")

# Append additional lines to file1
   awk '1; /MOL/ && ++n == m {print additional}' m="$num_lines_file1" additional="$additional_lines" "$state/$s0-$s1/frame${i}_change.gro" > "$state/$s0-$s1/frame${i}.gro"

   rm $state/$s0-$s1/frame${i}_change.gro

done

