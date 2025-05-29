#!/bin/csh
source /usr/local/gromacs/bin/GMXRC
GROMACS_EXEC="/usr/local/gromacs/bin/gmx"
MDP_0_1="../../../MDP/0_1.mdp"
MDP_1_0="../../../MDP/1_0.mdp"

#first run
#gmx grompp -f MDP/em0.mdp -o em0.tpr -c input.gro -r input.gro -p topol.top -n index.ndx -maxwarn 1
#gmx mdrun -deffnm em0 -nt 6 -nb gpu
#gmx grompp -f MDP/NVT0.mdp -o NVT0.tpr -c em0.gro -r em0.gro -p topol.top -n index.ndx -maxwarn 1
#gmx mdrun -deffnm NVT0 -nt 6 -nb gpu
#gmx grompp -f MDP/NPT0.mdp -o NPT0.tpr -c NVT0.gro -r NVT0.gro -p topol.top -n index.ndx -maxwarn 1
#gmx mdrun -deffnm NPT0 -nt 6 -nb gpu

#extracting frames
#mkdir traj0
#cd traj0
#echo "0" | gmx trjconv -s ../NPT0.tpr -f ../NPT0.xtc -o frame.gro -b 1 -pbc mol -ur compact -sep
#mkdir out_of_equilbrium_0
#cd out_of_equilbrium_0
# Create a directory to store the output files.
#mkdir -p output_files

# Loop over the frame numbers from 0 to 100.
#for frame_number in {0..500}; do
    # Construct the frame filename.
    #gro_file="../frame${frame_number}.gro"

    # Check if the frame file exists.
    #if [ -f "$gro_file" ]; then
        #echo "Processing frame: $frame_number"

        # Create a directory for this frame.
        #frame_dir="frame_${frame_number}"
        #mkdir -p "$frame_dir"
        #cd "$frame_dir"
        # Generate a .tpr file for this frame.
        #tpr_file="tpr${frame_number}.tpr"
        #$GROMACS_EXEC grompp -f $MDP_0_1 -p ../../../topol.top -c ../$gro_file -o $tpr_file -n ../../../index.ndx -maxwarn 1

        # Run gmx mdrun for this frame.
        #$GROMACS_EXEC mdrun -s $tpr_file -deffnm "tpr${frame_number}" -dhdl "dhdl_${frame_number}.xvg" -nt 6 -nb gpu
        #cd ..
        # Move the output files to the output directory.
        #mv "$frame_dir" output_files/
        #rm -r "$frame_dir"
    #else
        #echo "Frame file not found: $gro_file"
    #fi
#done
                                                                                                                                                                                                                   gmx grompp -f MDP/em1.mdp -o em1.tpr -c input.gro -r input.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm em1 -nt 6 -nb gpu
gmx grompp -f MDP/NVT1.mdp -o NVT1.tpr -c em1.gro -r em1.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm NVT1 -nt 6 -nb gpu
gmx grompp -f MDP/NPT1.mdp -o NPT1.tpr -c NVT1.gro -r NVT1.gro -p topol.top -n index.ndx -maxwarn 1
gmx mdrun -deffnm NPT1 -nt 6 -nb gpu

mkdir traj1
cd traj1 
echo "0" | gmx trjconv -s ../NPT1.tpr -f ../NPT1.xtc -o frame.gro -b 1 -pbc mol -ur compact -sep

mkdir out_of_equilbrium_1
cd out_of_equilbrium_1

# Create a directory to store the output files.
mkdir -p output_files

# Loop over the frame numbers from 0 to 100.
for frame_number in {0..500}; do
    # Construct the frame filename.
    gro_file="../frame${frame_number}.gro"

    # Check if the frame file exists.
    if [ -f "$gro_file" ]; then
        echo "Processing frame: $frame_number"

        # Create a directory for this frame.
        frame_dir="frame_${frame_number}"
        mkdir -p "$frame_dir"
        cd "$frame_dir"
        # Generate a .tpr file for this frame.
        tpr_file="tpr${frame_number}.tpr"
        $GROMACS_EXEC grompp -f $MDP_1_0 -p ../../../topol.top -c ../$gro_file -o $tpr_file -n ../../../index.ndx -maxwarn 1

        # Run gmx mdrun for this frame.
        $GROMACS_EXEC mdrun -s $tpr_file -deffnm "tpr${frame_number}" -dhdl "dhdl_${frame_number}.xvg" -nt 6 -nb gpu
        cd ..
        # Move the output files to the output directory.
        mv "$frame_dir" output_files/
        rm -r "$frame_dir"
    else
        echo "Frame file not found: $gro_file"
    fi
done
 
