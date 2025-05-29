#! /bin/bash


export GMX_MAXBACKUP=-1

system=water_test
state=0
s0=benzene
s1=toluene

for i in {0..99} 
do

	gmx_mpi grompp -f mdps/min_${state}_test.mdp -o ${system}/${s0}-${s1}/min_${state}_${i}.tpr -c ${system}/${s0}-${s1}/frame${i}.gro -r ${system}/${s0}-${s1}/frame${i}.gro -p ${system}/topol_${s0}-${s1}.top -n ${system}/${s0}-${s1}/index.ndx -maxwarn 2

	mpirun -np 1 gmx_mpi mdrun -deffnm ${system}/${s0}-${s1}/min_${state}_${i} -v -ntomp 14 -pin on -pinoffset 0

	gmx_mpi grompp -f mdps/NVT${state}.mdp -o ${system}/${s0}-${s1}/eq_${state}_${i}.tpr -c ${system}/${s0}-${s1}/min_${state}_${i}.gro -r ${system}/${s0}-${s1}/min_${state}_${i}.gro -p ${system}/topol_${s0}-${s1}.top -n ${system}/${s0}-${s1}/index.ndx -maxwarn 2

	mpirun -np 1 gmx_mpi mdrun -deffnm ${system}/${s0}-${s1}/eq_${state}_${i} -v -ntomp 14 -pin on -pinoffset 0

	cp ${system}/${s0}-${s1}/frame${i}.gro ${system}/${s0}-${s1}/frame${i}_inp.gro

file1="${system}/${s0}-${s1}/frame${i}_inp.gro"
file2="${system}/${s0}-${s1}/eq_${state}_${i}.gro"

sed '/MOL.*[[:space:]]\(D\|HV\)/d' "$file1" > temp

mv temp "$file1"

last_mol_index=$(grep -n "MOL" "$file1" | cut -d: -f1 | tail -n 1)

# Extract lines containing " D" or " HV" from file2 and append to file1
grep -E " D| HV" "$file2" | while read -r line; do
    indented_line="    $line"  # Add 4 spaces to the beginning of the line
    sed -i "${last_mol_index}a\\${indented_line}" "$file1"
    last_mol_index=$((last_mol_index + 1))
done


	gmx_mpi grompp -f mdps/noneq_${state}.mdp -o ${system}/${s0}-${s1}/noneq_${state}_${i}.tpr -c ${system}/${s0}-${s1}/frame${i}_inp.gro -r ${system}/${s0}-${s1}/frame${i}_inp.gro -p ${system}/topol_${s0}-${s1}.top -n ${system}/${s0}-${s1}/index.ndx -maxwarn 1

	mpirun -np 1 gmx_mpi mdrun -deffnm ${system}/${s0}-${s1}/noneq_${state}_${i} -v -ntomp 14 -pin on -pinoffset 0

done

system=water_test
state=0
s0=toluene
s1=benzene

for i in {0..99}
do

        gmx_mpi grompp -f mdps/min_${state}_test.mdp -o ${system}/${s0}-${s1}/min_${state}_${i}.tpr -c ${system}/${s0}-${s1}/frame${i}.gro -r ${system}/${s0}-${s1}/frame${i}.gro -p ${system}/topol_${s0}-${s1}.top -n ${system}/${s0}-${s1}/index.ndx -maxwarn 2

        mpirun -np 1 gmx_mpi mdrun -deffnm ${system}/${s0}-${s1}/min_${state}_${i} -v -ntomp 14 -pin on -pinoffset 0

        gmx_mpi grompp -f mdps/NVT${state}.mdp -o ${system}/${s0}-${s1}/eq_${state}_${i}.tpr -c ${system}/${s0}-${s1}/min_${state}_${i}.gro -r ${system}/${s0}-${s1}/min_${state}_${i}.gro -p ${system}/topol_${s0}-${s1}.top -n ${system}/${s0}-${s1}/index.ndx -maxwarn 2

        mpirun -np 1 gmx_mpi mdrun -deffnm ${system}/${s0}-${s1}/eq_${state}_${i} -v -ntomp 14 -pin on -pinoffset 0

        cp ${system}/${s0}-${s1}/frame${i}.gro ${system}/${s0}-${s1}/frame${i}_inp.gro

file1="${system}/${s0}-${s1}/frame${i}_inp.gro"
file2="${system}/${s0}-${s1}/eq_${state}_${i}.gro"

sed '/MOL.*[[:space:]]\(D\|HV\)/d' "$file1" > temp

mv temp "$file1"

last_mol_index=$(grep -n "MOL" "$file1" | cut -d: -f1 | tail -n 1)

# Extract lines containing " D" or " HV" from file2 and append to file1
grep -E " D| HV" "$file2" | while read -r line; do
    indented_line="    $line"  # Add 4 spaces to the beginning of the line
    sed -i "${last_mol_index}a\\${indented_line}" "$file1"
    last_mol_index=$((last_mol_index + 1))
done


        gmx_mpi grompp -f mdps/noneq_${state}.mdp -o ${system}/${s0}-${s1}/noneq_${state}_${i}.tpr -c ${system}/${s0}-${s1}/frame${i}_inp.gro -r ${system}/${s0}-${s1}/frame${i}_inp.gro -p ${system}/topol_${s0}-${s1}.top -n ${system}/${s0}-${s1}/index.ndx -maxwarn 1

        mpirun -np 1 gmx_mpi mdrun -deffnm ${system}/${s0}-${s1}/noneq_${state}_${i} -v -ntomp 14 -pin on -pinoffset 0

done

