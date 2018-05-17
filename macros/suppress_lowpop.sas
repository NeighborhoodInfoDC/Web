/**************************************************************************
 Program:  suppress_lowpop
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/19/2018
 Version:  SAS 9.4
 Environment:  Windows
 Description: Suppress geographies with low population
 Modifications: 

**************************************************************************/

%macro suppress_lowpop (in_check, out_check);

/* Use NCDB 2010 data to check for low pop */
data popcheck_&topic.&geosuf. ;
	set &ncdb10in.;

	%if %upcase( &source_geo ) = COUNTY %then %do;
	TotPop_2010 = TRCTPOP1;
	%end;

	%else %if %upcase( &source_geo ) = GEO2010 %then %do;
	TotPop_2010 = TRCTPOP1;
	%end;

	if TotPop_2010 < 100 then lowpop = 1;

	keep &geo. TotPop_2010 lowpop;
run;


/* Remove geographies with low population */
proc sql noprint;
	CREATE TABLE &out_check. AS
		SELECT *
		FROM &in_check.
		WHERE &geo. IN (SELECT &geo. FROM popcheck_&topic.&geosuf. WHERE (lowpop ^= 1)) ;
quit;

%mend suppress_lowpop;


/* End of Macro */
