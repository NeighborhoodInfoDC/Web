/**************************************************************************
 Program:  export_employment
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_employment (
datafile=,
metadatafile=
);

%let topic = employment ;

%macro ncdbloop (ds,ncdbyr);

data Ncdb_&ncdbyr._&topic.;

%if &ds. = ncdb %then %do;

	%if &ncdbyr. = 1990 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	start_date = '01jan90'd;
	end_date = '31dec90'd;
	%end;

	%else %if &ncdbyr. = 2000 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	start_date = '01jan00'd;
	end_date = '31dec00'd;
	%end;

	%else %if &ncdbyr. = 2010 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_2010_was15;

	start_date = '01jan10'd;
	end_date = '31dec10'd;
	%end;

	format start_date end_date date9. ;

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* County ID */
	ucounty=substr(geo2010,1,5);

	/* timeframe */
	timeframe = "&ncdbyr" ;
%end;

%else %do;

	set acs_all;
	%let ncdbyr = &acsyr.;

%end;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);

	%Pct_calc( var=PctUnemployed, label=Unemployment rate (%), num=PopUnemployed, den=PopInCivLaborForce, years= 1990 2000 &acsyr. );
	%Pct_calc( var=Pct16andOverEmployed, label=% pop. 16+ yrs. employed, num=Pop16andOverEmployed, den=Pop16andOverYears, years=1980 1990 2000 &acsyr. );
	


	keep geo2010_nf geo2010 start_date end_date timeframe
		 PctUnemployed_&ncdbyr. Pct16andOverEmployed_&ncdbyr.;

	rename 	PctUnemployed_&ncdbyr. = PctUnemployed
			Pct16andOverEmployed_&ncdbyr. = Pct16andOverEmployed
;


%if &ds. = acs %then %do;

	%Moe_prop_a( var=PctUnemployed_m_&acsyr., mult=100, num=PopUnemployed_&acsyr., den=PopInCivLaborForce_&acsyr., 
                       num_moe=mPopUnemployed_&acsyr., den_moe=mPopInCivLaborForce_&acsyr. );
    
    %Moe_prop_a( var=Pct16andOverEmployed_m_&acsyr., mult=100, num=Pop16andOverEmployed_&acsyr., den=Pop16andOverYears_&acsyr., 
                       num_moe=mPop16andOverEmployed_&acsyr., den_moe=mPop16andOverYears_&acsyr. );


	keep PctUnemployed_m_&acsyr. Pct16andOverEmployed_m_&acsyr. ;

	rename 	PctUnemployed_m_&acsyr. = PctUnemployed_m
			Pct16andOverEmployed_m_&acsyr. = Pct16andOverEmployed_m ;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);



data &topic._tr10;
	set Ncdb_acs_&topic. ncdb_2000_&topic. ncdb_1990_&topic. ;

	/* County ID */
	ucounty=substr(geo2010,1,5);
	drop ucounty;

	%indc_flag (countyvar = ucounty);

	label PctUnemployed = "Unemployment rate (%)"
		  Pct16andOverEmployed = "% pop. 16+ yrs. employed"
		  PctUnemployed_m = "Unemployment rate (%) MOE"
		  Pct16andOverEmployed_m = "% pop. 16+ yrs. employed MOE"
		  ;
run;


/* Create metadata for the dataset */
proc contents data = &topic._tr10 out = &topic._tr10_metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&metadatafile.";
	proc print data =&topic._tr10_metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&datafile.";
	proc print data =&topic._tr10 noobs;
	run;
ods csv close;


%mend export_employment;



/* End Macro */
