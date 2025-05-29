#!/bin/bash 

#MSUB -r gregrun                      # Job name
#MSUB -n 255                               # Number of tasks that will bne used in parallel mode
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



#..source
source ../config.h
#source ../software.h

#..LOCAL variables
PWD=`pwd`
srdir=$PWD/SRC
prev=../00-bound/

#..RETRIEVE files
cp -rp ${prev}/toppar ./
TMPD=./tmpl
if [ ! -d $TMPD ]; then mkdir $TMPD; fi
cp ${prev}/topol.top $TMPD/
cp ${prev}/prod.gro  $TMPD/init.gro
cp ${prev}/prod.cpt  $TMPD/init.cpt
cp ${prev}/restraints.itp $TMPD/

#..update topology for VBA restraints
#cd $TMPD/
#echo -e "\n#include \"restraints.itp\"" > AA
#cat topol.top AA > BB
#mv BB topol.top
#rm AA
#cd ../

#..local variables
itop=topol.top

#..LOOP over lambda
for ll in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
wkdir=$ll
cp -rp $TMPD  $wkdir/ 

#..RUN Gromacs
cd $wkdir/
ln -s ../toppar ./
cat $srdir/PROD.tmpl | \
sed s/YYYYY/$ll/g    > PROD.mdp
#
gmx_mpi grompp -f PROD.mdp -c init.gro -t init.cpt -p $itop -o alch.tpr -maxwarn 1 
#srun gmx_mpi mdrun -deffnm alch -v -ntomp $SLURM_CPUS_PER_TASK -pin on -pinoffset 0

#..store (checkpoint)
#cp alch.cpt ../$TMPD/init.cpt
#cp alch.gro ../$TMPD/init.gro

#..iterate
cd ../
done

ccc_mprun gmx_mpi mdrun -deffnm alch -multidir 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 -replex 1000 -v

