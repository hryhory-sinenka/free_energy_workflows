{
	cc=0;
	for(ii=2;ii<=NF;ii++){
		cc++;
		mean[$1]+=$ii; 
		mnsq[$1]+=$ii*$ii;
	}
	mean[$1]/=cc;
	mnsq[$1]/=cc;
}
END{
	for(ii=1;ii<NR;ii++){
#		print ii, mean[ii], mnsq[ii], sqrt(mnsq[ii]-mean[ii]*mean[ii]);
		printf("%3d %7.2f %7.2f\n", ii, mean[ii], sqrt(mnsq[ii]-mean[ii]*mean[ii]) );
	}
}
