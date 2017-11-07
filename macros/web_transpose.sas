/**************************************************************************
 Program:  Web_Transpose
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Sybil Mendonca
 Created:  10/25/2017
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Transform NIDC summary data from wide to long for website. 

 Modifications:
10/30/2017: 
1)Added a new parameter COND in the macro widetolong. The parameter
gives the user an option to either add a keep or a drop statement if needed. -SM
2) Added macro runquit. It stops processing SAS statements once it encounters an error. -SM

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( Vital )
%DCData_lib( TANF )
%DCData_lib( Web )



%macro runquit;
  ; run; quit;
  %if &syserr. ne 0 %then %do;
     %abort cancel;
  %end;
%mend runquit;


%macro web_transpose (library, datacat, indata, source_geo, StrtYr, EndYr, keepvars);
proc datasets library =work;
	delete &TypeOfDat. &TypeOfDat._o&StrtYr. - &TypeOfDat._o&EndYr. 
			&TypeOfDat._AllYears_Long &TypeOfDat._Long_Yr&StrtYr. - &TypeOfDat._Long_Yr&EndYr. ;
run;

/* Define macro variables for this macro based on NIDC geography */
 %if %upcase( &source_geo ) = TR00 %then %do;
     %let sortvar = GEO2000;
     %let TypeOfDat = TR00;
  %end;
  %else %if %upcase( &source_geo ) = TR10 %then %do;
     %let sortvar = GEO2010;
     %let TypeOfDat = TR10;
  %end;
  %else %if %upcase( &source_geo ) = ANC2002 %then %do;
     %let sortvar = ANC2002;
     %let TypeOfDat = ANC02;
  %end;
  %else %if %upcase( &source_geo ) = ANC2012 %then %do;
     %let sortvar = ANC2012;
     %let TypeOfDat = ANC12;
  %end;
  %else %if %upcase( &source_geo ) = CITY %then %do;
     %let sortvar = CITY;
     %let TypeOfDat = CITY;
  %end;
  %else %if %upcase( &source_geo ) = CLTR00 %then %do;
     %let sortvar = CLUSTER_TR2000;
     %let TypeOfDat = CLTR00;
  %end;
  %else %if %upcase( &source_geo ) = PSA04 %then %do;
     %let sortvar = PSA2004;
     %let TypeOfDat = PSA04;
  %end;
  %else %if %upcase( &source_geo ) = PAS12 %then %do;
     %let sortvar = PSA2012;
     %let TypeOfDat = PSA12;
  %end;
  %else %if %upcase( &source_geo ) = WD02 %then %do;
     %let sortvar = WARD2002;
     %let TypeOfDat = WD02;
  %end;
  %else %if %upcase( &source_geo ) = WD12 %then %do;
     %let sortvar = WARD2012;
     %let TypeOfDat = WD12;
  %end;
  %else %do;
    %err_mput( macro= ACS_summary_geo_source, msg=Geograpy &source_geo is not supported. )
  %end;


/* Read in summary data and keep only variables that will be transposed */
data &TypeOfDat.;
	set &library..&indata._&TypeOfDat. ; 
	keep &sortvar.;

	%macro keeploop();
		%let varlist = &keepvars.;
			%let i = 1;
				%do %until (%scan(&varlist,&i,' ')=);
					%let var=%scan(&varlist,&i,' ');
			keep &var._&StrtYr. - &var._&EndYr. ;
		%let i=%eval(&i + 1);
				%end;
			%let i = 1;
				%do %until (%scan(&varlist,&i,' ')=);
					%let var=%scan(&varlist,&i,' ');
		%let i=%eval(&i + 1);
				%end;
	%mend keeploop;
	%keeploop;


run;

%runquit;
proc sql noprint;
	/*Variable names without the year component are stored in individual macro variables var_listi */
   select distinct  substr(name,1, length(name)-5)
          into :var_list1 - :var_list999        
          from dictionary.columns
          where libname = 'WORK' and memname = "&TypeOfDat." and UPCASE(NAME) ne "&sortvar." ;
	/*No of variables: The automatic macro variable SQLOBS is assigned a value after the SQL SELECT statement executes */
	%let nu= &sqlobs. ;
quit;

%runquit;
%put &nu. ;


 %do j = 1 %to &nu. ;
  %put "Variable we are processing:" &&var_list&j.. ; 

  	proc sort data =&TypeOfDat.;
		by &sortvar.;
	run;
	%runquit;
	data &TypeOfDat._o&j.(keep = &Sortvar. &&var_list&j.. timeframe ) ;
 	set &TypeOfDat.(keep = &Sortvar. &&var_list&j.._&Strtyr. -&&var_list&j.._&Endyr.) ;
 	by &Sortvar.;

  	&&var_list&j.. =0;
 	length name2 $32 timeframe $4.;

	array crimesm&j.{*} &&var_list&j.._&StrtYr. -&&var_list&j.._&EndYr. ;
	do i =1 to dim(crimesm&j.);
			&&var_list&j.. =crimesm&j.{i};
			/*Assigns the variable name specified in the array crimes as the value of a specified variable name2*/
			call vname(crimesm&j.{i},name2); 
			/*year or timeframe*/
			timeframe = substr(name2, max(1,length(name2)-3));
			output;
	end;
	run;
	%runquit;
%end;

/*Merge all the variable datasets together*/
data &TypeOfDat._AllYears_Long;
	format start_date end_date date9. ;
	merge &TypeOfDat._o1 -&TypeOfDat._o&nu. ;
	by &Sortvar.;
	start_date = mdy(01, 01, timeframe);
	end_date = mdy(12, 31, timeframe); 
run;
/* Output all years CSV */
ods csv file ="&_dcdata_default_path.\web\output\&datacat.\&TypeOfDat.\&datacat._&TypeOfDat._AllYears.csv";
	proc print data = &TypeOfDat._AllYears_Long noobs;
	run;
ods csv close;



/*Subset datasets by year */
%do i = &StrtYr. %to &EndYr.;
data &TypeOfDat._Long_Yr&i. ;
	set &TypeOfDat._AllYears_Long;
	where timeframe ="&i." ;
run;
%runquit;
/* Output each year as a separate CSV */
ods csv file ="&_dcdata_default_path.\web\output\&datacat.\&TypeOfDat.\&datacat._&TypeOfDat._&i..csv";
	proc print data =&TypeOfDat._Long_Yr&i. noobs;
	run;
ods csv close;
%end;

proc datasets library =work;
	delete &TypeOfDat._o1 - &TypeOfDat._o&nu.  ;
run;
quit;
%mend web_transpose;




%web_transpose(police, crime, crimes_sum, WD12, 2000, 2016, crimes_pt1 Crimes_pt1_property Crimes_pt1_violent );
%web_transpose(police, crime, crimes_sum, ANC2012, 2000, 2016, crimes_pt1 Crimes_pt1_property Crimes_pt1_violent );

%web_transpose(vital, vital, births_sum_wd12, WD12, 2008, 2011, births_total Births_white Births_black);

%web_transpose(tanf, tanf, tanf_sum_wd12, WD12, 2010, 2015, Tanf_client Tanf_fulpart);
%web_transpose(tanf, fs, fs_sum_wd12, WD12, 2010, 2015, fs_client fs_fulpart);
