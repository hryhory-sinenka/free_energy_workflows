#!/bin/csh
source /usr/local/gromacs/bin/GMXRC
gmx grompp -f MDP/em0.mdp -o em0.tpr -c input.gro -r input.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm em0 -nt 6 -nb gpu
gmx grompp -f MDP/NVT0.mdp -o NVT0.tpr -c em0.gro -r em0.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm NVT0 -nt 6 -nb gpu
gmx grompp -f MDP/NPT0.mdp -o NPT0.tpr -c NVT0.gro -r NVT0.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm NPT0 -nt 6 -nb gpu

#extracting frames
#mkdir traj0
#cd traj0
#gmx trjconv -s ../NPT0.tpr -f ../NPT0.xtc -o frame.gro -b 1 -pbc mol -ur compact -sep
