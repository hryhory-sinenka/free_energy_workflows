#-----------------------------------------------------------------------STAT
BEGIN{
    j2cal=1/4.184;
    if (VERBOSE=="")
        VERBOSE=0;
}
substr($0,1,1)!="#"{
  ll[NR]=$1;
  dhdl[NR]=$2;
}
END{
    #..trapezoidal integration
    sum=0;
    for(ii=1; ii<NR; ii++){
	bb=dhdl[ii];
	BB=dhdl[ii+1];
	hh=ll[ii+1]-ll[ii];
	dA=0.5*(BB+bb)*hh;
	sum+=dA;
	if (VERBOSE)
	   printf("%7.4f %9.5f %9.5f\n", ll[ii], dA*j2cal, sum*j2cal);
    }
    printf("%7.5f kcal/mol\n", sum*j2cal);
}
#-------------------------------------------------------------------------------------------STAT
