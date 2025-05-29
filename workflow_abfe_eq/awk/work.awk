#-----------------------------------------------------------------------STAT
BEGIN{
# Checking...
    if ((IFILE == "")) {
	printf ( "\nUsage:\n");
	printf ( "\tawk -f work.awk -v IFILE=file.kappa -v IFILE2=file.sigma \n" );
	printf ( "\n" );
	exit;
    }
    #..constants
    pi=3.14159;
    kb=1.38064852e-23; #..J/K
    Na=6.02214086e23;  #..mol-1
    j2cal=1/4.184;

    #..data
    Temp=298;    #..K 
    V=1.66058;   #..nm^3/molecule (volume/molecule @ 1M)

#..example (KAPPA)
#    krr=4184;    #..kJ/mol/nm^2
#    ktt=41.84;   #..kJ/mol/rad^2
#    kpp=41.84;   #..kJ/mol/rad^2
#    kTHE=41.84;  #..kJ/mol/rad^2
#    kPHI=41.84;  #..kJ/mol/rad^2
#    kPSI=41.84;  #..kJ/mol/rad^2
#    R0=0.405;    #..nm
#    tt0=2.65;    #..rad
#    TT0=1.40;    #..rad

    #..read KAPPA
    while ( (getline < IFILE) > 0 )
	if (substr($0,1,1)!="#"){
	    cc++;
	    DATA[cc]=$1
	}
    	#..SET values
    	krr=DATA[1];
    	ktt=DATA[2];
    	kpp=DATA[3];
    	kTHE=DATA[4];
    	kPHI=DATA[5];
    	kPSI=DATA[6];
    	R0=DATA[7];
    	tt0=DATA[8];
    	TT0=DATA[9];
#..check!    NDAT=cc;
#..check!    for(ii=1;ii<=NDAT;ii++)
#..check!       print ii, DATA[ii];
#..check!	exit;

#..example (SIGMA)   
#sigma_L         1
#sigma_P         14
#sigma_PL        1
	if(IFILE2){
	cc=0;
	while ( (getline < IFILE2) > 0 )
		if (substr($0,1,1)!="#"){
			cc++;
			DAT2[cc]=$2
		}
		#..SET values
		sigma_L=DAT2[1];
		sigma_P=DAT2[2];
		sigma_PL=DAT2[3];
	}
#..check!    		NDAT=cc;	
#..check!        	for(ii=1;ii<=NDAT;ii++)
#..check!			print ii, SIGMA[ii];
#..check!	exit;


#..kT
	kT=kb*Na*Temp/1000; #..kJ/mol
#..check!    print kT;

	#..positional restraint
	Ztr=V;
	Ztr_R=R0^2 * sin(tt0) * (2*pi*kT)^(3/2) /sqrt(krr*ktt*kpp);
#	print R0^2, sin(tt0), (2*pi*kT)^(3/2);
#	exit;
#..check!    print "log(Ztr/Ztr_R):\t", log(Ztr/Ztr_R);

   	 #..orientation restraint
   	 Zrot=8*pi^2;
   	 Zrot_R=sin(TT0) * (2*pi*kT)^(3/2)/sqrt(kTHE*kPHI*kPSI);
#..check!    print "log(Zrot/Zrot_R):", log(Zrot/Zrot_R);

    	#..Restraint work
    	Wr = -kT*(log(Ztr_R/Ztr)+log(Zrot_R/Zrot));

    	#..Symmetry correction
	if(IFILE2)
    		W_corr=-kT*(log(sigma_L*sigma_P/sigma_PL));

	#..print out
	if(IFILE2 && VERBOSE){
		printf("Wr:\t %9.5f kcal/mol\n", Wr*j2cal);
		printf("Wcorr:\t %9.5f kcal/mol\n", W_corr*j2cal);
		printf("Wtot:\t %9.5f kcal/mol\n", (Wr+W_corr)*j2cal);
	}
	else
    		printf("%9.5f kcal/mol\n", (Wr+W_corr)*j2cal);
}
#-------------------------------------------------------------------------------------------STAT
