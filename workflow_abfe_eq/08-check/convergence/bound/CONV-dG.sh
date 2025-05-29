#..local
wkdir=`pwd`
awkd=../../../awk/

#..loop over replicas
for job in R1 R2 R3 R4; do	
	srdir=../../../03-alchemical-bound/${job}
	
	#..prepare for convergence analysis
	cd ${srdir}
	./ANAL.sh

	#..convergence analysis
	cd ${wkdir}
	mkdir ${job}
	for tt in 50 100 200 500 1000 2000; do 
		echo "$tt";
		mkdir tmp;

		for ii in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36; do 
			echo "$ii"; 
			awk -v NDAT=${tt} '(substr($1,1)=="#" || substr($1,1)=="@" || $1<=NDAT)' $srdir/dhdl-files/dhdl_${ii}.xvg > tmp/dhdl_${ii}.xvg; 
		done; 

		#..do analysis
		${awkd}/abfe.py ./tmp/;
        	grep -v INFO results.txt | grep -v DEBUG  | grep -v WARN > $tt.dG;

		#..clean
		rm -rf tmp;
		rm results.txt;
		rm *.pdf;
	done

	#..report
	grep TOT 50.dG 100.dG 200.dG 500.dG 1000.dG 2000.dG | sed s/\.dG://g > data;

	#..clean
	mv data ${job}
	mv *.dG ${job}
done
