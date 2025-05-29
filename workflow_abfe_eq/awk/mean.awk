#-------------------------------------------------------MEAN
BEGIN{
  if ( col == "" ) {
    print "";
    print " ERR>";
    print "     Missing  parameter - col : ";
    exit;
  }
}
substr($0,1,1)!="#"{
  cc++;
  data[cc] = $col;
#...check!!!    print mean[cc], mnsq[cc]; 
}
END{
  nDat = cc;
  
  for(ii=1; ii<=nDat; ii++){
    mean += data[ii];
    mnsq += data[ii] * data[ii];
  }

  mean/=nDat;
  mnsq/=nDat;

  varia = mnsq - (mean * mean);
  printf ( "Mean: %9.5f \t Sigma:%9.5f\n", mean, sqrt(varia) );
}
#-------------------------------------------------------MEAN
