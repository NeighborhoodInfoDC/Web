/**************************************************************************
 Program:  Macro WideToLong
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Sybil Mendonca
 Created:  10/25/2017
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Transform NIDC data from wide to long.

 Modifications:
10/30/2017: 
1)Added a new parameter COND in the macro widetolong. The parameter
gives the user an option to either add a keep or a drop statement if needed.
2) Added macro runquit. It stops processing SAS statements once it encounters an error.

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( Vital )
%DCData_lib( Web )


*************************************;
*************************************;
*************************************;
*Macro WideToLong;
*************************************;
*Dat - Input dataset;
*SortVar - Sort or the BY variable. Should be Uppercase.;
*TypeOfDat - Type of dataset. e.g. WD12, ANC2002 etc. ;
*StrtYr - Start Year;
*EndYr - End year;
*************************************;
*************************************;
*************************************;
%macro runquit;
  ; run; quit;
  %if &syserr. ne 0 %then %do;
     %abort cancel;
  %end;
%mend runquit;

%macro widetolong(dat, sortvar, TypeOfDat, StrtYr, EndYr, cond);
proc datasets library =work;
	delete &TypeOfDat. &TypeOfDat._o&StrtYr. - &TypeOfDat._o&EndYr. 
			&TypeOfDat._AllYears_Long &TypeOfDat._Long_Yr&StrtYr. - &TypeOfDat._Long_Yr&EndYr. ;
run;

%let sortvar   = %upcase(&sortvar.);
%let TypeOfDat = %upcase(&TypeOfDat.);

*created a work dataset so that I do not overwrite the actual file;
data &TypeOfDat.;
	set &dat. &cond.;
run;
%runquit;
proc sql noprint;
	*Variable names without the year component are stored in individual macro variables var_listi;
   select distinct  substr(name,1, length(name)-5)
          into :var_list1 - :var_list999        
          from dictionary.columns
          where libname = 'WORK' and memname = "&TypeOfDat." and UPCASE(NAME) ne "&sortvar." ;

	*No of variables: The automatic macro variable SQLOBS is assigned a value after the SQL SELECT statement executes.;
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
			*Assigns the variable name specified in the array crimes as the value of a specified variable name2;
			call vname(crimesm&j.{i},name2); 
			*year or timeframe;
			timeframe = substr(name2, max(1,length(name2)-3));
			output;
	end;
	run;
	%runquit;
%end;

*Merge all the variable datasets together;
data &TypeOfDat._AllYears_Long;
	format start_date end_date date9. ;
	merge &TypeOfDat._o1 -&TypeOfDat._o&nu. ;
	by &Sortvar.;
	start_date = mdy(01, 01, timeframe);
	end_date = mdy(12, 31, timeframe); 
run;
ods csv file ="D:\DCData\Libraries\Web\output\&TypeOfDat._AllYears_Long.csv";
	proc print data = &TypeOfDat._AllYears_Long noobs;
	run;
ods csv close;



*data sets by year;
%do i = &StrtYr. %to &EndYr.;
data &TypeOfDat._Long_Yr&i. ;
	set &TypeOfDat._AllYears_Long;
	where timeframe ="&i." ;
run;
%runquit;
ods csv file ="D:\DCData\Libraries\Web\output\&TypeOfDat._Long_Yr&i..csv";
	proc print data =&TypeOfDat._Long_Yr&i. noobs;
	run;
ods csv close;
%end;

proc datasets library =work;
	delete &TypeOfDat._o1 - &TypeOfDat._o&nu.  ;
run;
quit;
%mend;

%widetolong(police.crimes_sum_wd12, WARD2012, WD12, 2000, 2016, %str((drop= Crimes_pt1_2000 - Crimes_pt1_2016)) );
%widetolong(police.crimes_sum_wd12, WARD2012, WD12, 2000, 2016, %str((keep=  Ward2012 Crimes_pt1_2000 - Crimes_pt1_2016)) );
%widetolong(police.crimes_sum_wd12, WARD2012, WD12, 2000, 2016,  );

/**example of how runquit works.;*/
/**The Sortvar variable is not mentioned in the keep statemnet. This should result in the program failing; */
/*%widetolong(police.crimes_sum_wd12, WARD2012, WD12, 2000, 2016, %str((keep=  Crimes_pt1_2000 - Crimes_pt1_2016)) );*/


%widetolong(police.Crimes_sum_anc02, ANC2002, ANC2002, 2000, 2016);
%widetolong(police.Crimes_sum_anc12, ANC2012, ANC2012, 2000, 2016);
/*%widetolong(police.Crimes_sum_bl00, GeoBlk2000, BL100, 2000, 2016);*/
%widetolong(police.Crimes_sum_tr10, GEO2010, TR10, 2000, 2016);

