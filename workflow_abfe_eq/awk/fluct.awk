#
#..awk -v X0=XX -v LAMBDA=YY -v KF=ZZ -v col=$ii -v DIHE=1 -f fluct.awk  file.cv
#
BEGIN{
	pi=3.14159265359;
	if(DIHE=="")
		DIHE=0;
}
substr($0,1,1)!="#"{
	cc++;
	if (DIHE){
		dd=$col-X0;
		absd=sqrt(dd*dd);
		if(absd > pi)
			delta=(2*pi)-absd;
		else
			delta=absd;
		sum+=(delta*delta);
	}
	else{
		delta=$col-X0;
                sum+=(delta*delta);
	}
}
END{
	printf( "%12.7f %9.5f\n", LAMBDA, (KF/2)*(sum/cc) );
}
