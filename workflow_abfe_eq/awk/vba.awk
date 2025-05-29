#
#..awk -f vba.awk -v IFILE=file.dat -v LAMBDA=XXX  file.vba
#
BEGIN{
# Checking...
	if ( (LAMBDA=="")  || (IFILE=="") ){
		printf ( "\nUsage:\n");
		printf ( "\tawk -f vba.awk -v IFILE=file.dat -v LAMBDA=XXX  file.vba\n\n" );
		printf ( "\n" );
		exit;
    	}
#..local	
pi=3.14159265359;
#..read IFILE
	while ( (getline < IFILE) > 0 ){
		if (substr($0,1,1)!="#"){
			cv++;
			kf[cv]=$1;
			ref[cv]=$2;
			dihe[cv]=$3;
		}
		nCV=cv;
	}
}
substr($0,1,1)!="#"{
	cc++;
	for (ii=1;ii<=NF;ii++)
		CV[ii,cc]=$ii;
}
END{
	nFR=cc;
	#print "nCV:", nCV;
	#print "nFR:", nFR;
	#exit;

	#..loop over CVs
	for (ii=1;ii<=nCV;ii++){
		sum[ii]=0;
		X0=ref[ii];
		DIHE=dihe[ii];
		#print "X0:", X0;
		#print "DIHE:", DIHE;
		#..loop over FRAMES
		for (jj=1;jj<=nFR;jj++){
			Xi=CV[ii,jj];
			#..collect fluctuations
		        if (DIHE){
                		dd=Xi-X0;
                		absd=sqrt(dd*dd);
                		if(absd > pi)
                        		delta=(2*pi)-absd;
                		else
                        		delta=absd;
                			sum[ii]+=(delta*delta);
        		}
        		else{
                		delta=Xi-X0;
                		sum[ii]+=(delta*delta);
        		}
		}
	}

	#..PRINT OUT
	printf( "%12.7f", LAMBDA);
	for (ii=1;ii<=nCV;ii++)
		printf( "%12.5f", (kf[ii]/2)*(sum[ii]/nFR) );
	printf( "\n");
}
