#
#..awk -f kappa.awk -v LAMBDA=XX -v TMPL= file.tmpl -v OUT=file.dat file.kappa
#
BEGIN{
# Checking...
    if ( (LAMBDA == "")  || (TMPL == "") )
    {
	printf ( "\nUsage:\n");
	printf ( "\tawk -f kappa.awk -v LAMBDA=XX -v TMPL=file.tmpl -v OUT=file.dat file.kappa\n\n" );
	printf ( "\n" );
	exit;
    }
}
substr($0,1,1)!="#"{
    cc++;
    KF[cc]=$1;
}
END{
    #..update KAPPA
    for(ii=1;ii<=cc;ii++)
	KK[ii]=KF[ii]*LAMBDA;
		
    #..write VBA.DAT (plumed)
    while ( (getline < TMPL) > 0 ) 
    {
	gsub(/KK1/, KK[1]);
	gsub(/KK2/, KK[2]);
	gsub(/KK3/, KK[3]);
	gsub(/KK4/, KK[4]); 	    
	gsub(/KK5/, KK[5]);
	gsub(/KK6/, KK[6]); 
	print > OUT;
    }
}
