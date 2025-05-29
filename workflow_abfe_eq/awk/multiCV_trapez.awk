#-----------------------------------------------------------------------STAT
BEGIN{
    	j2cal=1/4.184;
    	if (VERBOSE=="")
        	VERBOSE=0;
}
substr($0,1,1)!="#"{
	ll[NR]=$1;
	for (ii=2;ii<=NF;ii++){
		cv=ii-1;
     		dhdl[cv,NR]=$ii;
	}
}
END{
	nCV=NF-1;
	nLL=NR;
#	print "nCV:", nCV;
#	print "nLL:", nLL;
#..check!
#	for(ii=1; ii<=nCV; ii++){
#		for(jj=1; jj<=nLL; jj++){
#			print ll[ii], dhdl[ii,jj];
#		}
#		print "\n";
#	} 
#	exit;

	#..trapezoidal integration
   	SUM=0;
    	#..loop over CVs
    	for(ii=1; ii<=nCV; ii++){ 
#		print "CV:", ii;
		sum[ii]=0;
		#..loop over LAMBDA
		for(jj=1; jj<nLL; jj++){
			bb=dhdl[ii,jj];
			BB=dhdl[ii,jj+1];
			hh=ll[jj+1]-ll[jj];
			dA=0.5*(BB+bb)*hh;
			sum[ii]+=dA;
			if (VERBOSE)
	   			printf("%2d %7.5f %7.5f %7.5f\n", ii, ll[jj+1], dA*j2cal, sum[ii]*j2cal);
    		}
		if (VERBOSE)
			printf("#%7.5f kcal/mol\n\n\n", sum[ii]*j2cal);
		else
			printf("%7.5f kcal/mol\n", sum[ii]*j2cal);
	}
}
#-------------------------------------------------------------------------------------------STAT
