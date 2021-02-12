/**************************************************************************
 Program:  HMDA_forweb
 Library:  HMDA
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/16/2017
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( HMDA )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = hmda; /* Library of the summary data to be transposed */
%let outfolder = hmda; /* Name of folder where output CSV will be saved */
%let sumdata = hmda_sum; /* Summary dataset name (without geo suffix) */
%let start = 1997; /* Start year */
%let end = 2018; /* End year */
%let keepvars = NumMrtgOrigHomePurch1_4m HUnits 
           NumConvMrtgOrigHomePurch MedianMrtgInc1_4m ; /*NumSubprimeConvOrigHomePur  ;  Summary variables to keep and transpose */


/***** Update the web_varcreate marcro if you need to create final indicators for the website after transposing *****/

%macro web_varcreate;

NumMrtgOrigHomePurchPerUnit = NumMrtgOrigHomePurch1_4m / HUnits *1000;
*PctSubprimeConvOrigHomePur = NumSubprimeConvOrigHomePur / NumConvMrtgOrigHomePurch;

label NumMrtgOrigHomePurchPerUnit = "Loans per 1,000 housing units";
*label PctSubprimeConvOrigHomePur = "% subprime loans";
*label MedianMrtgInc1_4m_adj = "Median borrower income";
label MedianMrtgInc1_4m = "Median borrower income";


drop NumMrtgOrigHomePurch1_4m NumMrtgOrigHomePurch1_4m /*NumSubprimeConvOrigHomePur*/ NumConvMrtgOrigHomePurch HUnits;

%mend web_varcreate;



/**************** DO NOT UPDATE BELOW THIS LINE ****************/

%macro csv_create(geo);

%if %upcase( &geo ) = TR10 %then %do;
     %let sortvar = GEO2010;
  %end;
%else %if %upcase( &geo ) = COUNTY %then %do;
     %let sortvar = COUNTY;
  %end;
%else %if %upcase( &geo ) = CITY %then %do;
     %let sortvar = CITY;
  %end;
%else %if %upcase( &geo ) = WD12 %then %do;
     %let sortvar = WARD2012;
  %end;
%else %if %upcase( &geo ) = ANC12 %then %do;
     %let sortvar = ANC2012;
  %end;
 %else %if %upcase( &geo ) = CLTR00 %then %do;
     %let sortvar = CLUSTER_TR2000;
  %end;
 %else %if %upcase( &geo ) = PSA12 %then %do;
     %let sortvar = PSA2012;
  %end;
 %else %if %upcase( &geo ) = ZIP %then %do;
     %let sortvar = ZIP;
  %end;
 %else %if %upcase( &geo ) = CL17 %then %do;
     %let sortvar = CLUSTER2017;
  %end;

%housing_unit_count (&geo.);

proc sort data = Ncdb_hu_count_&geo.; by &sortvar.; run;
proc sort data = &library..&sumdata._&geo. out = &sumdata._&geo.; by &sortvar.; run;
proc sort data = &library..&sumdata._p09_&geo. out = &sumdata._p09_&geo.; by &sortvar.; run;

data &sumdata._all_&geo.;
	merge &sumdata._&geo. &sumdata._p09_&geo. Ncdb_hu_count_&geo.;
	by &sortvar.;
run;

%web_transpose(work, &outfolder., &sumdata._all, &geo., &start., &end., &keepvars. );
			


/* Load transposed data, create indicators for profiles */
data &sumdata._&geo._long_allyr;
	set &sumdata._all_&geo._long;
	%web_varcreate;
	label start_date = "Start Date"
		  end_date = "End Date"
		  timeframe = "Year of Data";
run;

/* Create metadata for the dataset */
proc contents data = &sumdata._&geo._long_allyr out = &sumdata._&geo._metadata noprint;
run;

%mend csv_create;
%csv_create (tr10);
%csv_create (anc12);
%csv_create (wd12);
%csv_create (city);
%csv_create (psa12);
%csv_create (zip);
%csv_create (cl17);

