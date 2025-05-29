#!/bin/bash 

#MSUB -r gregrun                      # Job name
#MSUB -n 228                               # Number of tasks that will bne used in parallel mode
#MSUB -c 2                              # number of cores per parallel task to allocate
#MSUB -T 86400                         # Elapsed time limit in seconds of the job (default:7200 )
#MSUB -Q normal                            # Qualtiy of Service
#MSUB -o RUN_out.o                         # Standard output. %I is the job id
#MSUB -e RUN_error.e                       # Error output. %I is the job id
#MSUB -A gen6644                         # Project ID
#MSUB -q rome                            # Partition name (see ccc_mpinfo)
#MSUB -m scratch                         # spécifier le système de fichiers à utiliser
##MSUB -@ khaled.mehy-dine@etu.unistra.fr #sends an email at the end of the job  

export OMP_NUM_THREADS=2 # Match with -c

module purge

module load gcc/11
module load nvhpc/23.7
module load gromacs/2024.4


#source /home2020/home/isis/sinenko/gromacs_plumed/plumed2-master/sourceme.sh
#source /home2020/home/isis/sinenko/gromacs_plumed/gromacs-2022.5/GROMACS/bin/GMXRC.bash

for ll in {0..56}; do
  mkdir lambda_$ll
  cd lambda_$ll


#..source
source ../../../config.h
#source ../../software.h
#guest=1K0

#..LOCAL variables
PWD=`pwd`
srdir=$PWD/../SRC
prev=../../../02-vba-bound-Greg1

#..RETRIEVE files
cp -rp ../../../00-bound/toppar ./
#..get last VBA
cd  ${prev}; LAST=`ls -1d ? ?? | sort -nk 1 | tail -1`; cd -
#TMPD=./tmp
#if [ ! -d $TMPD ]; then mkdir $TMPD; fi
cp ${prev}/$LAST/topol.top ./
cp ${prev}/$LAST/restraints.itp ./
cp ${prev}/$LAST/alch.gro init.gro
cp ${prev}/$LAST/alch.cpt init.cpt


#..local variables
itop=topol.top

current_dir=$(basename "$PWD")

# Extract the number from the directory name
if [[ $current_dir =~ lambda_([0-9]+) ]]; then
    n=${BASH_REMATCH[1]}
fi

#cat $srdir/step4.0_minimization_1.tmpl | \
#sed s/YYYYY/$n/g    | \
#sed s/NNNNN/${guest}/g > step4.0_minimization_1.mdp

#cat $srdir/step4.0_minimization_2.tmpl | \
#sed s/YYYYY/$n/g    | \
#sed s/NNNNN/${guest}/g > step4.0_minimization_2.mdp

#cat $srdir/step4.1_equilibration_1.tmpl | \
#sed s/YYYYY/$n/g    | \
#sed s/NNNNN/${guest}/g > step4.1_equilibration_1.mdp

#cat $srdir/step4.1_equilibration_2.tmpl | \
#sed s/YYYYY/$n/g    | \
#sed s/NNNNN/${guest}/g > step4.1_equilibration_2.mdp

#cat $srdir/step4.1_equilibration_3.tmpl | \
#sed s/YYYYY/$n/g    | \
#sed s/NNNNN/${guest}/g > step4.1_equilibration_3.mdp

#cat $srdir/step4.1_equilibration_4.tmpl | \
#sed s/YYYYY/$n/g    | \
#sed s/NNNNN/${guest}/g > step4.1_equilibration_4.mdp

cat $srdir/PROD.tmpl | \
sed s/YYYYY/$n/g    | \
sed s/NNNNN/${guest}/g > PROD.mdp
#

#gmx_mpi grompp -f step4.0_minimization_1.mdp -c init.gro -r init.gro -p $itop -o min_1.tpr -maxwarn 1
#srun gmx_mpi mdrun -deffnm min_1 -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

#gmx_mpi grompp -f step4.0_minimization_2.mdp -c min_1.gro -r init.gro -p $itop -o min_2.tpr -maxwarn 1
#srun gmx_mpi mdrun -deffnm min_2 -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

#gmx_mpi grompp -f step4.1_equilibration_1.mdp -c min_2.gro -r init.gro -p $itop -o equil_1.tpr -maxwarn 1
#srun gmx_mpi mdrun -deffnm equil_1 -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

#gmx_mpi grompp -f step4.1_equilibration_2.mdp -c equil_1.gro -t equil_1.cpt -r init.gro -p $itop -o equil_2.tpr -maxwarn 1
#srun gmx_mpi mdrun -deffnm equil_2 -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

#gmx_mpi grompp -f step4.1_equilibration_3.mdp -c equil_2.gro -t equil_2.cpt -r init.gro -p $itop -o equil_3.tpr -maxwarn 1
#srun gmx_mpi mdrun -deffnm equil_3 -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

#gmx_mpi grompp -f step4.1_equilibration_4.mdp -c equil_3.gro -t equil_3.cpt -r init.gro -p $itop -o equil_4.tpr -maxwarn 1
#srun gmx_mpi mdrun -deffnm equil_4 -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

gmx_mpi grompp -f PROD.mdp -c init.gro -t init.cpt -p $itop -o alch.tpr -maxwarn 1
#mpirun gmx_mpi mdrun -deffnm alch -plumed plumed.dat -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

cd ..
done

ccc_mprun gmx_mpi mdrun -deffnm alch -multidir lambda_0 lambda_1 lambda_2 lambda_3 lambda_4 lambda_5 lambda_6 lambda_7 lambda_8 lambda_9 lambda_10 lambda_11 lambda_12 lambda_13 lambda_14 lambda_15 lambda_16 lambda_17 lambda_18 lambda_19 lambda_20 lambda_21 lambda_22 lambda_23 lambda_24 lambda_25 lambda_26 lambda_27 lambda_28 lambda_29 lambda_30 lambda_31 lambda_32 lambda_33 lambda_34 lambda_35 lambda_36 lambda_37 lambda_38 lambda_39 lambda_40 lambda_41 lambda_42 lambda_43 lambda_44 lambda_45 lambda_46 lambda_47 lambda_48 lambda_49 lambda_50 lambda_51 lambda_52 lambda_53 lambda_54 lambda_55 lambda_56 -replex 1000  -v

#for ll in {0..35}; do
#  cd lambda_$ll

#find . -type f ! -name "*.xvg" -delete

#cd ..
#done

#..store (checkpoint)
#rm \#* bck.*
