#!/bin/bash

#It is important to read all the comments.

#We need python2 to run script cgenff2pmx.py by Adrien Cerdan. So be sure that when running this script you are using conda environment with python2.

#This is the first script to run in the automatic nonequilibrium workflow. This workflow takes the non-hybrid trajectories of two ligands and then prepares the hybrid frames to run the nonequilibrium alchemical transformations for each frame. It does it both based on the frames from the trajectory of the first ligand, and vice versa. 

#As well, this script performs some file extraction work to create adequate topology files, add missing atomtypes in case some ligand does not have those which another one has, etc.

#This script is preparing everything to generate the hybrid topologies for each frame extracted from trajectory of both ligands, but the last stage of their generation is in the script_Gregory_1.sh script. In here, the geometries of ligands on which we will base the hybrid topologies are taken from the CHARMM-GUI equilibration last frame step4.1_equilibration.gro. In difficult cases of conformationally labile ligands, you may want to reflect on that, as well as you may want to divide your trajectory into two clusters with different hybrid topologies and so on.

#It should be noted that this approach is sometimes problematic in cases where less symmetrical ligand is aligned into more symmetrical one. For example, aligning toluene onto benzene is non-invariant, as it depends on where the pmx code will put the methyl group with respect of the binding site. Hovewer, in real-life applications and lead optimization it should not play a big role, as such a symmetrical molecules probably would not be encountered.

#These scripts are symmetrical with respect to the names like s0 or s1. It means that the scripts have two parts: in one s0=benzene and s1=toluene, and in the other vice versa: s0=toluene and s1=benzene.

# Step 1)
#One should follow the next commands to prepare the input files and rename them appropriately. This will work only if the CHARMM-GUI output folders are structured in the same way.

state=water_test
s0=benzene
s1=toluene
ligand_0=BENZ
ligand_1=TOLU

# we delete the previous folder of the same name to avoid accumulated errors, we recreate it
# we create all the other needed folders for the systems of both ligands
rm -r ${state}
mkdir ${state}

mkdir ${state}/${s0}
mkdir ${state}/${s0}/pmx
mkdir ${state}/${s1}
mkdir ${state}/${s1}/pmx
mkdir ${state}/${s0}-${s1}
mkdir ${state}/${s0}-${s1}/pmx
mkdir ${state}/${s1}-${s0}
mkdir ${state}/${s1}-${s0}/pmx

# we transfer the input files for the systems of both ligands

cp Water/${s0}_water/gromacs/toppar/${ligand_0}.itp ${state}/${s0}/pmx/MOL.itp
cp Water/${s0}_water/gromacs/toppar/forcefield.itp ${state}/${s0}/pmx/forcefield.prm
gmx_mpi editconf -f Water/${s0}_water/gromacs/step4.1_equilibration.gro -o Water/${s0}_water/gromacs/step4.1_equilibration.pdb
cat Water/${s0}_water/gromacs/step4.1_equilibration.pdb | grep ${ligand_0} > ${state}/${s0}/pmx/${s0}.pdb
sed -i "s/${ligand_0}/MOL/g" "${state}/${s0}/pmx/${s0}.pdb"
sed -i "s/${ligand_0}/MOL/g" "${state}/${s0}/pmx/MOL.itp"
cp Water/${s0}_water/gromacs/step5_production.trr ${state}/${s0}/step5_production.trr
cp Water/${s0}_water/gromacs/step5_production.tpr ${state}/${s0}/step5_production.tpr
cp -r Water/${s0}_water/gromacs/toppar ${state}/toppar_${s0}
cp -r Water/${s0}_water/gromacs/topol.top ${state}/topol_${s0}-${s1}.top


cp Water/${s1}_water/gromacs/toppar/${ligand_1}.itp ${state}/${s1}/pmx/MOL.itp
cp Water/${s1}_water/gromacs/toppar/forcefield.itp ${state}/${s1}/pmx/forcefield.prm
gmx_mpi editconf -f Water/${s1}_water/gromacs/step4.1_equilibration.gro -o Water/${s1}_water/gromacs/step4.1_equilibration.pdb
cat Water/${s1}_water/gromacs/step4.1_equilibration.pdb | grep ${ligand_1} > ${state}/${s1}/pmx/${s1}.pdb
sed -i "s/${ligand_1}/MOL/g" "${state}/${s1}/pmx/${s1}.pdb"
sed -i "s/${ligand_1}/MOL/g" "${state}/${s1}/pmx/MOL.itp"
cp Water/${s1}_water/gromacs/step5_production.trr ${state}/${s1}/step5_production.trr
cp Water/${s1}_water/gromacs/step5_production.tpr ${state}/${s1}/step5_production.tpr
cp -r Water/${s1}_water/gromacs/toppar ${state}/toppar_${s1}
cp -r Water/${s1}_water/gromacs/topol.top ${state}/topol_${s1}-${s0}.top

#We extract the [ atomtypes ] group from both forcefield.itp files of two ligands, we delete it from forcefield.itp files and store it in the file parameters.itp. Then, for both ligands we modify parameters.itp files so that they both contain all the atomtypes lacking either in the original forcefield.itp of first or second ligands.

#We extract [ defaults ] group as well in a separate file - because in forcefield.itp it goes before [ atomtypes ], while only [ atomtypes ] must be merged later between two ligands. It is important to ensure that [ defaults ] group in topol.top is referenced always first. 

input_file0=${state}/toppar_${s0}/forcefield.itp
input_file1=${state}/toppar_${s1}/forcefield.itp
temp_file0=${state}/toppar_${s0}/temp_extracted_section.itp
temp_file1=${state}/toppar_${s1}/temp_extracted_section.itp

sed -n '/\[ defaults \]/,/^$/p' ${input_file0} > ${temp_file0}
sed -i '/\[ defaults \]/,/^$/d' ${input_file0}
sed -n '/\[ defaults \]/,/^$/p' ${input_file1} > ${temp_file1}
sed -i '/\[ defaults \]/,/^$/d' ${input_file1}
mv ${temp_file0} ${state}/${s0}/pmx/defaults.itp
mv ${temp_file1} ${state}/${s1}/pmx/defaults.itp

sed -n '/\[ atomtypes \]/,/^$/p' ${input_file0} > ${temp_file0}
sed -i '/\[ atomtypes \]/,/^$/d' ${input_file0}
sed -n '/\[ atomtypes \]/,/^$/p' ${input_file1} > ${temp_file1}
sed -i '/\[ atomtypes \]/,/^$/d' ${input_file1}
mv ${temp_file0} ${state}/${s0}/pmx/parameters.itp
mv ${temp_file1} ${state}/${s1}/pmx/parameters.itp

file1="${state}/${s0}/pmx/parameters.itp"
file2="${state}/${s1}/pmx/parameters.itp"

awk -v file1="$file1" '
    FNR == NR {
        words[$1] = 1;
        next;
    }
    {
        if ($1 in words) {
            words[$1] = 2;
        } else {
            if (file1 != "") {
                print >> file1;
            }
        }
    }
    END {
        if (file1 != "") {
            close(file1);
        }
    }
' "${file1}" "${file2}"

cp ${file1} ${file2}

sed -n '/\[ nonbond_params \]/,/^$/p' ${input_file0} > ${temp_file0}
sed -i '/\[ nonbond_params \]/,/^$/d' ${input_file0}
sed -n '/\[ nonbond_params \]/,/^$/p' ${input_file1} > ${temp_file1}
sed -i '/\[ nonbond_params \]/,/^$/d' ${input_file1}
mv ${temp_file0} ${state}/${s0}/pmx/nonbonded.itp
mv ${temp_file1} ${state}/${s1}/pmx/nonbonded.itp

file1="${state}/${s0}/pmx/nonbonded.itp"
file2="${state}/${s1}/pmx/nonbonded.itp"

awk -v file1="$file1" '
    FNR == NR {
        words[$1] = 1;
        next;
    }
    {
        if ($1 in words) {
            words[$1] = 2;
        } else {
            if (file1 != "") {
                print >> file1;
            }
        }
    }
    END {
        if (file1 != "") {
            close(file1);
        }
    }
' "${file1}" "${file2}"

cp ${file1} ${file2}


# The next part of the script is done only for the first ligand, and in the end of the script is symmetrically re-done for the second

#We change the contents of topol.top file, including MOL.itp and ffmerged.itp:

old_path="toppar"
new_path="toppar_${s0}"

sed -i "s#$old_path/forcefield.itp#$new_path/forcefield.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/${ligand_0}.itp#${s0}-${s1}/pmx/MOL_to_be_used.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/SOD.itp#$new_path/SOD.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/ACET.itp#$new_path/ACET.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/TIP3.itp#$new_path/TIP3.itp#g" $state/topol_${s0}-${s1}.top

id=$(($(grep -n -m 1 forcefield.itp "$state/topol_${s0}-${s1}.top" | sed 's/\([0-9]*\).*/\1/')))
line_to_insert="#include \"${s0}/pmx/parameters.itp\""
sed -i "${id}i $line_to_insert" "$state/topol_${s0}-${s1}.top"

id=$(($(grep -n -m 1 parameters.itp "$state/topol_${s0}-${s1}.top" | sed 's/\([0-9]*\).*/\1/')))
line_to_insert="#include \"${s0}/pmx/defaults.itp\""
sed -i "${id}i $line_to_insert" "$state/topol_${s0}-${s1}.top"

id=$(($(grep -n -m 1 forcefield.itp "$state/topol_${s0}-${s1}.top" | sed 's/\([0-9]*\).*/\1/')))
line_to_insert="#include \"${s0}/pmx/nonbonded.itp\""
sed -i "${id}i $line_to_insert" "$state/topol_${s0}-${s1}.top"

sed -i "s/${ligand_0}/MOL/g" "${state}/topol_${s0}-${s1}.top"

# Step 2)
#Delete POSRES group in the end of MOL.itp file. One must check if in the original CHARMM-GUI files the BEN.itp and TOLU.itp indeed have this group only in the end of the file.

sed -i '/#ifdef POSRES/,$d' ${state}/${s0}/pmx/MOL.itp

# Step 3)
#The next command is needed to change the numbering in the .pdb input files, as otherwise pmx has difficulties in processing them

gmx_mpi editconf -f ${state}/${s0}/pmx/${s0}.pdb -o ${state}/${s0}/pmx/${s0}.pdb


# Step 4)
#Then, we create topologies in a pmx-readable format.

python cgenff2pmx.py -i $state/$s0/pmx/MOL.itp -p $state/$s0/pmx/forcefield.prm -s $state/$s0/pmx/$s0.pdb -o $state/$s0/pmx/ffmol.itp

# Step 5)
#We do all the same, but inverting the ligand names. 

state=water_test
s0=toluene
s1=benzene
ligand_0=TOLU
ligand_1=BENZ

old_path="toppar"
new_path="toppar_${s0}"

sed -i "s#$old_path/forcefield.itp#$new_path/forcefield.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/${ligand_0}.itp#${s0}-${s1}/pmx/MOL_to_be_used.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/SOD.itp#$new_path/SOD.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/ACET.itp#$new_path/ACET.itp#g" $state/topol_${s0}-${s1}.top
sed -i "s#$old_path/TIP3.itp#$new_path/TIP3.itp#g" $state/topol_${s0}-${s1}.top

id=$(($(grep -n -m 1 forcefield.itp "$state/topol_${s0}-${s1}.top" | sed 's/\([0-9]*\).*/\1/')))
line_to_insert="#include \"${s0}/pmx/parameters.itp\""
sed -i "${id}i $line_to_insert" "$state/topol_${s0}-${s1}.top"

id=$(($(grep -n -m 1 parameters.itp "$state/topol_${s0}-${s1}.top" | sed 's/\([0-9]*\).*/\1/')))
line_to_insert="#include \"${s0}/pmx/defaults.itp\""
sed -i "${id}i $line_to_insert" "$state/topol_${s0}-${s1}.top"

id=$(($(grep -n -m 1 forcefield.itp "$state/topol_${s0}-${s1}.top" | sed 's/\([0-9]*\).*/\1/')))
line_to_insert="#include \"${s0}/pmx/nonbonded.itp\""
sed -i "${id}i $line_to_insert" "$state/topol_${s0}-${s1}.top"

sed -i "s/${ligand_0}/MOL/g" "${state}/topol_${s0}-${s1}.top"



sed -i '/#ifdef POSRES/,$d' ${state}/${s0}/pmx/MOL.itp



gmx_mpi editconf -f ${state}/${s0}/pmx/${s0}.pdb -o ${state}/${s0}/pmx/${s0}.pdb



python cgenff2pmx.py -i $state/$s0/pmx/MOL.itp -p $state/$s0/pmx/forcefield.prm -s $state/$s0/pmx/$s0.pdb -o $state/$s0/pmx/ffmol.itp
