#!/bin/csh
gmx grompp -f MDP/em1.mdp -o em1.tpr -c input.gro -r input.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm em1 -nt 6 -nb gpu
gmx grompp -f MDP/NVT1.mdp -o NVT1.tpr -c em1.gro -r em1.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm NVT1 -nt 6 -nb gpu
gmx grompp -f MDP/NPT1.mdp -o NPT1.tpr -c NVT1.gro -r NVT1.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm NPT1 -nt 6 -nb gpu
