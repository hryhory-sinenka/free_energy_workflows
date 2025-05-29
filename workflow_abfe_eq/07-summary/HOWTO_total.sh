#!/bin/bash

#..source
source ../config.h
source ../software.h

#..LOCAL variables
wkdir=`pwd`

#..RETRIEVE files

#..02-vba-bound
cd ../02-vba-bound
pwd
FILE=dhdl-files/results.txt
if [ ! -f $FILE ]; then
./ANAL.sh >& /tmp/out 
fi
grep TOT $FILE | awk '{print $2}' > $wkdir/VBA_BND.dG

#..03-alchemical-boun
cd ../03-alchemical-bound
FILE=dhdl-files/results.txt
for ii in `ls -1d R*`; do 
	cd $ii; 
	pwd; 
	if [ ! -f $FILE ]; then 
		./ANAL.sh >& /tmp/out;
	fi	
	cd ../; 
done 
grep TOT R*/dhdl-files/results.txt | awk -f ~/Repository/awk/mean.awk -v col=7 | \
       	awk '{print $2}' > $wkdir/ALCH_BND.dG

#..05-alchemical-unbound
cd ../05-alchemical-unbound
FILE=dhdl-files/results.txt
for ii in `ls -1d R*`; do 
        cd $ii; 
        pwd; 
        if [ ! -f $FILE ]; then 
                ./ANAL.sh >& /tmp/out; 
        fi      
        cd ../; 
done
grep TOT R*/dhdl-files/results.txt | awk -f ~/Repository/awk/mean.awk -v col=7 | \
        awk '{print $2}' > $wkdir/ALCH_UB.dG

#..06-work-unbound/
cd ../06-work-unbound/
pwd
./HOWTO_vba-UB.sh > $wkdir/VBA_UB.dG

#..printing summary
cd $wkdir
FILE="dG"
if [ -f $FILE ]; then
rm $FILE
fi

echo -e "\n --> SUMMARY <--"

#..restrain LIGAND in UNBOUND state
echo "VBA_UB"
cat VBA_UB.dG  | awk '{print  $2, "kcal/mol"}'
cat VBA_UB.dG  | awk '{print  $2, "kcal/mol"}' | tail -1 >> dG
echo ""

#..decouple LIGAND in UNBOUND state
echo "ALCH_UB"
cat ALCH_UB.dG | awk '{print $1, "kcal/mol"}'
cat ALCH_UB.dG | awk '{print $1, "kcal/mol"}' >> dG

#..recouple  LIGAND in BOUND state
echo "ALCH_BND"
cat ALCH_BND.dG | awk '{print -$1, "kcal/mol"}'
cat ALCH_BND.dG | awk '{print -$1, "kcal/mol"}' >> dG
echo ""

#..release LIGAND in BOUND state
echo "VBA_BND"
cat VBA_BND.dG  | awk '{print  -$1, "kcal/mol"}' 
cat VBA_BND.dG  | awk '{print  -$1, "kcal/mol"}' >> dG
echo ""

#..summary
awk -v ID=$GUEST '{sum+=$1}END{printf("DDM> %s %7.2f kcal/mol\n", ID, sum)}' dG
