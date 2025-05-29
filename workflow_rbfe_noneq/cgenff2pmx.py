#!/usr/bin/env python
# coding: utf-8

import sys, getopt, os, re, shutil

def read_bonds(bond,prm_file):
    file2 = open(prm_file, 'r')
    Lines2 = file2.readlines()
    part_bonds=0
    for line in Lines2:
        if not line.strip(): #skip empty line
            continue
        LL=line.strip()
        # find the bonds section
        if LL == "[ bondtypes ]":
            part_bonds=1
            continue
        if part_bonds==1:
            if LL[0]==";":
                continue
            elif LL[0]=="[": # end of the bonds section
                part_bonds=0
                continue
            else:
                # split the string
                bond_ff=LL.split()[0:]
                # test the atoms involved in the bond in both direction
                if (bond_ff[0:2] == bond) or (bond_ff[0:2] == bond[::-1]):
                    # return the bond parameter from the .prm
                    return bond_ff

def read_angles(angle,prm_file):
    # similar to read bond but with 3 atoms involved
    file2 = open(prm_file, 'r')
    Lines2 = file2.readlines()
    part_angles=0
    for line in Lines2:
        if not line.strip(): #skip empty line
            continue
        LL=line.strip()
        if LL == "[ angletypes ]":
            part_angles=1
            continue
        if part_angles==1:
            if LL[0]==";":
                continue
            elif LL[0]=="[":
                part_angles=0
                continue
            else:
                angle_ff=LL.split()[0:]
                if (angle_ff[0:3] == angle) or (angle_ff[0:3] == angle[::-1]) :
                    return angle_ff

def read_dihedrals(dihedral,prm_file):
    # similar to read bond but with 4 atoms involved
    # also works with duplicated dihedral section with impropers from cgenff, but all dihedrals are merged
    file2 = open(prm_file, 'r')
    Lines2 = file2.readlines()
    part_dihedrals=0
    for line in Lines2:
        if not line.strip(): #skip empty line
            continue
        LL=line.strip()
        if LL == "[ dihedraltypes ]":
            part_dihedrals=1
            continue
        if part_dihedrals==1:
            if LL[0]==";":
                continue
            elif LL[0]=="[":
                part_dihedrals=0
                continue
            else:
                dihedral_ff=LL.split()[0:]
                if (dihedral_ff[0:4] == dihedral) or (dihedral_ff[0:4] == dihedral[::-1]):
                    return dihedral_ff

# MAIN #
# should handles errors if the bond-angle-dihedral types are missing in the .prm while using read_*
def main(argv):
    print(' $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')
    print(' $            CGENFF2PMX.py          $')
    print(' $ Parse .itp and .prm to merge them $')
    print(' $ from cgenff_charmm2gmx.py to PMX  $')
    print(' $ By Adrien Cerdan 2022             $')
    print(' $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')

    inputitp = ''
    inputprm = ''
    inputpdb = ''
    outputitp = ''
    pdbispresent=0
    try:
        opts, args = getopt.getopt(argv,"hs:i:p:o:",["iitpfile=","iprmfile=","ipdbfile=","oitpfile="])
    except getopt.GetoptError:
        print('cgenff2pmx.py -i <inputfileITP> -p <inputfilePRM> -s <inputfilePDB> -o <outputfileITP>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('cgenff2pmx.py -i <inputfileITP> -p <inputfilePRM> -s <inputfilePDB> -o <outputfileITP>')
            sys.exit()
        elif opt in ("-i", "--iitpfile"):
            inputitp = arg
        elif opt in ("-p", "--iprmfile"):
            inputprm = arg
        elif opt in ("-s", "--ipdbfile"):
            inputpdb = arg
            pdbispresent=1
        elif opt in ("-o", "--oitpfile"):
            outputitp = arg
    print('Input itp file is ', inputitp)
    print('Input prm file is ', inputprm)
    if pdbispresent==1:
        print('Input pdb file is ', inputpdb)
    print('Output itp file is ', outputitp)

    file1 = open(inputitp, 'r')
    Lines1 = file1.readlines()

    count = 0
    part_moleculetype=0
    part_atoms=0
    part_bonds=0
    part_pairs=0
    part_angles=0
    part_dihedrals=0
    part_vs=0
    part_exclusions=0
    dict_atoms={}
    with open(outputitp, 'w') as f:
        f.write('; $ CGENFF2PMX.py $\n')
        f.write('; Parse .itp and .prm to merge them\n')
        f.write('; from cgenff_charmm2gmx.py to PMX\n')
        f.write('; By Adrien Cerdan 2022 \n')
        f.write('\n')
    # Read lines
    for line in Lines1:
        if not line.strip(): #skip empty line
            continue
        LL=line.strip()
        # Enter moleculetype section: check if it can contains some usefull information but should be ok
        if LL == "[ moleculetype ]":
            if part_moleculetype==0:
                #print('moleculetype')
                with open(outputitp, 'a') as f:
                    f.writelines(LL)
                part_moleculetype=1
                continue 
        if part_moleculetype==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ atoms ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_moleculetype=0
                part_atoms=1
                #print("atoms")
                continue
            else:
                pairs_out=LL.split()
                #print(pairs_out)
                with open(outputitp, 'a') as f:
                    for line in pairs_out:
                        f.write('    '+"".join(line) + "\t")
                    f.writelines('\n')
                continue
        # Enter atoms section: nothing to do, just copy
        if part_atoms==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    f.writelines(LL+'\n')
                continue
            elif LL[0]=="[":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_atoms=0
                part_bonds=1
                #print("bonds")
                continue
            else:
                #print(LL)
                atom_line=LL.split()
                if LL.split()[4][0]=='L':
                    print("LP detected for atom: ",LL.split()[0])
                    if pdbispresent==1:
                        print("Old line: ", atom_line)
                        list_atom_name=list(atom_line[4])
                        list_atom_name[0]="E"
                        str_atom_name=''.join(list_atom_name)
                        atom_line[4]=str_atom_name
                        print("New line: ", atom_line)
                        backuppdb=inputpdb+".bck"
                        print("Backup .pdb: ",inputpdb," into :",backuppdb)
                        shutil.copyfile(inputpdb, backuppdb)
                        print("Modifying .pdb")
                        with open(inputpdb, "r") as sources:
                            lines = sources.readlines()
                        with open(inputpdb, "w") as sources:
                            for line in lines:
                                sources.write(re.sub("LP", 'EP', line))
                    else:
                        if os.path.exists(outputitp):
                            os.remove(outputitp)
                        else:
                            print("The file does not exist")
                        sys.exit("ERROR\nLP is detected and needs to be corrected in .pdb but the file was not provided.\nPlease submit a .pdb with the option -s file.pdb.\nAbnormal termination. ERROR.")
                with open(outputitp, 'a') as f:
                    for line in atom_line:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                    #f.writelines('    '+LL+'\n')
                # Create the dictionary where atom number is associated to an atom type to read .prm
                idx_atom=int(LL.split()[0])
                atom_type=LL.split()[1]
                dict_atoms[idx_atom]=atom_type
        # Enter bonds section: use read_bonds on .prm then copy
        if part_bonds==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ pairs ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_bonds=0
                part_pairs=1
                #print("pairs")
                continue
            else:
                # read atom indexes forming the bond
                bond_idx=LL.split()[0:2]
                bond=[dict_atoms[int(bond_idx[0])],dict_atoms[int(bond_idx[1])]]
                # read the parameters from .prm using read_bonds
                bond_ff=read_bonds(bond,inputprm)
                bond_ff[0]=bond_idx[0]
                bond_ff[1]=bond_idx[1]
                with open(outputitp, 'a') as f:
                    for line in bond_ff:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                #print(bond_ff)
                continue
        # Enter pairs section: nothing tot do I guess, just copy
        if part_pairs==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ angles ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_pairs=0
                part_angles=1
                #print("angles")
                continue
            else:
                pairs_out=LL.split()
                #print(pairs_out)
                with open(outputitp, 'a') as f:
                    for line in pairs_out:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                continue
        # Enter Angles section: use read_angles to extract them from .prm
        if part_angles==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    #f.writelines('\n')
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ dihedrals ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_angles=0
                part_dihedrals=1
                #print("dihedrals")
                continue
            else:
                # like in bonds but with angles
                angle_idx=LL.split()[0:3]
                angle=[dict_atoms[int(angle_idx[0])],dict_atoms[int(angle_idx[1])],dict_atoms[int(angle_idx[2])]]
                angle_ff=read_angles(angle,inputprm)
                angle_ff[0]=angle_idx[0]
                angle_ff[1]=angle_idx[1]
                angle_ff[2]=angle_idx[2]
                with open(outputitp, 'a') as f:
                    for line in angle_ff:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                #print(angle_ff)
                continue
        # enter in dihedral section: read_dihedrals is called to extract them from .prm
        if part_dihedrals==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    #f.writelines('\n')
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ dihedrals ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_angles=0
                part_dihedrals=1
                #print("dihedrals2")
                continue
            #elif re.search('[ virtual_sites. ]', LL):
            #elif fnmatch.fnmatch(LL,"[ virtual_sites? ]"):
            elif LL=="[ virtual_sites2 ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_dihedrals=0
                part_vs=1
                #print("VS")
                continue
            elif LL=="[ virtual_sites3 ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_dihedrals=0
                part_vs=1
                #print("VS")
                continue
            elif LL=="[ exclusions ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_vs=0
                part_exclusions=1
                #print("angles")
                continue
            else:
                # like bonds and angles
                dihedral_idx=LL.split()[0:4]
                dihedral=[dict_atoms[int(dihedral_idx[0])],dict_atoms[int(dihedral_idx[1])],dict_atoms[int(dihedral_idx[2])],dict_atoms[int(dihedral_idx[3])]]
                dihedral_ff=read_dihedrals(dihedral,inputprm)
                dihedral_ff[0]=dihedral_idx[0]
                dihedral_ff[1]=dihedral_idx[1]
                dihedral_ff[2]=dihedral_idx[2]
                dihedral_ff[3]=dihedral_idx[3]
                with open(outputitp, 'a') as f:
                    for line in dihedral_ff:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                #print(dihedral_ff)
                continue
        # Enter virtual site section: nothing to do I guess, just copy
        if part_vs==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ exclusions ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_vs=0
                part_exclusions=1
                #print("angles")
                continue
            elif LL=="[ virtual_sites3 ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_dihedrals=0
                part_vs=1
                #print("VS")
                continue
            else:
                pairs_out=LL.split()
                #print(pairs_out)
                with open(outputitp, 'a') as f:
                    for line in pairs_out:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                continue
        # Enter exclusions section: nothing to do I guess, just copy
        if part_exclusions==1:
            if LL[0]==";":
                with open(outputitp, 'a') as f:
                    f.writelines(LL+'\n')
                continue
            elif LL=="[ exclusions ]":
                with open(outputitp, 'a') as f:
                    f.writelines('\n')
                    f.writelines(LL+'\n')
                part_vs=0
                part_exclusions=1
                #print("angles")
                continue
            else:
                pairs_out=LL.split()
                #print(pairs_out)
                with open(outputitp, 'a') as f:
                    for line in pairs_out:
                        f.write("\t"+"".join(line))
                    f.writelines('\n')
                continue
#print(dict_atoms)

if __name__ == "__main__":
    main(sys.argv[1:])


