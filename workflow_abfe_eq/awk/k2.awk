#..awk -f k2.awk -v TMPL=vba_bias.tmpl -v LAMBDA=1 -v X0=file.x0 -v KK=file.kappa -v KRMS=file.krms -v OUT=plumed.inp
#
BEGIN{
# Checking...
    if ( (LAMBDA=="")  || (TMPL=="") || (X0=="") || (KK=="")  || (KRMS=="") )
    {
	printf ( "\nUsage:\n");
	printf ( "\tawk -f k2.awk -v TMPL=vba_bias.tmpl -v LAMBDA=1 -v X0=file.x0 -v KK=file.kappa -v KRMS=file.krms -v OUT=plumed.inp\n\n" );
	printf ( "\n" );
	exit;
    }
	print LAMBDA, TMPL, X0, KK, KRMS;
#..check!	exit;

	#..read X0
	cc=0
	while ( (getline < X0) > 0 ){
		if (substr($0,1,1)!="#"){
			cc++;
			ref[cc]=$1;
		}
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
        #..read KRMS
        while ( (getline < KRMS) > 0 ){
                if (substr($0,1,1)!="#"){
                        krms=$1;
                }
        }
#	#..check!
#	print cc;
#        for(ii=1;ii<=cc;ii++)
#                print ii, ref[ii], kappa[ii];
#        exit;

    	#..write VBA.DAT (plumed)
    	while ( (getline < TMPL) > 0 ) 
	{
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
