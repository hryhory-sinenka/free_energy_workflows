BEGIN{
        # Checking...
        if ( (PLMD == "")  || (TMPL == "") ) {
                 printf ( "\nUsage:\n\n")
                 printf ( "\tawk -f prep_restraints-itp.awk -v HEAD=\"config.h\"" );
                 printf ( "-v PLMD=\"plumed.out\" -v TMPL=\"restraints.tmpl\" -v OUT=\"restraints.itp\"" );
                 printf ( "\n" );
		 printf ( "\t\t HEAD = config file\n" );
		 printf ( "\t\t PLMD = PLUMDED output\n" );
                 printf ( "\t\t TMPL = template\n" );
                 printf ( "\n" );
		 exit;
        }

	#..conversion factor (rad to deg)
	rad2deg=57.29578;

	#..READ anchor-point IDs
#       HEAD="config.h"
#        while ( (getline < HEAD) > 0 ){
#                if ($1=="P1")
#                        atomID["P1"]=$2;
#                else if ($1=="P2")
#                        atomID["P2"]=$2;
#                else if ($1=="P3")
#                        atomID["P3"]=$2;
#                else if ($1=="L1")
#                        atomID["L1"]=$2;
#                else if ($1=="L2")
#                        atomID["L2"]=$2;
#                else if ($1=="L3")
#                        atomID["L3"]=$2;
#        }
#        close(INP);

#..check!! 	for (ii in atomID)
#..check!!               print ii, atomID[ii];


	#..READ reference values
#	PLUMED="BOUND"
        while ( (getline < PLMD) > 0 ){
		tag=1;
		#..skip header
		if(substr($0,1,1)!="#"){
			#..colect ref values
			for(ii=3;ii<=NF;ii++){
                        	if(ii==3){
                                	REF=("REF" tag);
                                	value[REF]=$ii;
                                	tag++;
				}
                        	else{
					REF=("REF" tag);
                                	value[REF]=$ii*rad2deg;
                                	tag++
                        	}
                	}
        	}
	}
#..check!!      for (ii in value)
#..check!!               print ii, value[ii];

	#..WRITE restraints.itp
#       TMPL="restraints.tmpl"
        while ( (getline < TMPL) > 0 ){
#                gsub(/P1/, atomID["P1"]);
#                gsub(/P2/, atomID["P2"]);
#                gsub(/P3/, atomID["P3"]);
#                gsub(/L1/, atomID["L1"]);
#                gsub(/L2/, atomID["L2"]);
#                gsub(/L3/, atomID["L3"]);
#                
		gsub(/REF1/, value["REF1"]);
                gsub(/REF2/, value["REF2"]);
                gsub(/REF3/, value["REF3"]);
                gsub(/REF4/, value["REF4"]);
                gsub(/REF5/, value["REF5"]);
                gsub(/REF6/, value["REF6"]);
                print;
        }
        close(TMPL);
}
