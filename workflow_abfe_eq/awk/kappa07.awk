#
#..awk -f kappa.awk -v LAMBDA=XX -v TMPL= file.tmpl -v OUT=file.dat file.kappa
#
BEGIN{
# Checking...
	if ( (LAMBDA=="")  || (KK=="") || (KRMS=="") || (X0=="") || (TMPL=="") ){
		printf ( "\nUsage:\n");
		printf ( "\tawk -f kappa.awk -v LAMBDA=XX -v TMPL=file.tmpl -v OUT=file.dat file.kappa\n\n" );
		printf ( "\n" );
		exit;
    	}
        #..read KAPPA
        cc=0;
        while ( (getline < KK) > 0 ){
		if (substr($0,1,1)!="#"){
			cc++;
                        kf[cc]=$1;
                        kk[cc]=kf[cc]*LAMBDA;
                }
        }
        #..read X0
        cc=0;
        while ( (getline < X0) > 0 ){
                if (substr($0,1,1)!="#"){
                        cc++;
                        ref[cc]=$1;
                }
        }
        #..read KRMS
        while ( (getline < KRMS) > 0 ){
                if (substr($0,1,1)!="#"){
                        krms=$1;
                }
        }
    	#..write VBA.DAT (plumed)
    	while ( (getline < TMPL) > 0 ) {
		gsub(/KK1/, kk[1]);
		gsub(/KK2/, kk[2]);
		gsub(/KK3/, kk[3]);
		gsub(/KK4/, kk[4]); 	    
		gsub(/KK5/, kk[5]);
		gsub(/KK6/, kk[6]); 
		gsub(/REF1/, ref[1]);
                gsub(/REF2/, ref[2]);
                gsub(/REF3/, ref[3]);
                gsub(/REF4/, ref[4]);
                gsub(/REF5/, ref[5]);
                gsub(/REF6/, ref[6]);
		gsub(/KRMS/, krms);
		print > OUT;
    	}
}
