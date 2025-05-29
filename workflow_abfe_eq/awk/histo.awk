BEGIN{
  if ( NBIN == "" || col == "" ) {
    print "";
    print " ERR>";
    print "     Missing  parameter - NBIN: number of bins";
    print "     Missing  parameter - col : ";
    print "";
    print "     Optional parameter - MAX: ";
    print "     Optional parameter - MIN: ";
    print "";
    print "     Optional parameter - yy: ";
    print "     Optional parameter - colyy: (MANDATORY when yy==1)";
    print "";
    exit;
  }
  maxe=-2000000;
  mine=+2000000;
}
substr($0,1,1)!="#"{
  cc++;
  data[cc]=$col;
  YYdata[cc]=$colyy;	
  if(maxe<data[cc]){
    maxe=data[cc];
  }
  if(mine>data[cc]){
    mine=data[cc];
  }
}
END{
  if ( MIN != "" ) {
    mine = MIN;
  }
  if ( MAX != "" ) {
    maxe = MAX;
  }
  nDat = cc;
  deltamaxmin=maxe-mine;
  dd=deltamaxmin/NBIN;
  for(i=1;i<=NBIN;i++){
    histo[i]=0;
  }
  for(j=1;j<=nDat;j++){
    histo[int((data[j]-mine)/dd)]++;
    if ( yy==1 ) {
      YYhisto[int((data[j]-mine)/dd)]+=YYdata[j];
    }
  }
  for(i=0;i<=NBIN;i++){
    if ( histo[i]!=0) {
      if ( yy==1 ) {
	print mine+dd*i, YYhisto[i]/histo[i];
      }
      else {
	print mine+dd*i, histo[i];
      }
    }
  }
}
