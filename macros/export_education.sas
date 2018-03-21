/**************************************************************************
 Program:  export_education
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_education (source_geo);

%let topic = education ;

%if %upcase( &source_geo ) = GEO2010 %then %do;
     %let geo = geo2010;
     %let geosuf = _tr10;
     %let ncdb00in = ncdb.Ncdb_sum_was15_tr10;
	 %let ncdb10in = ncdb.Ncdb_2010_was15;
	 %let acsin = acs.acs_&acsyr._dc_sum_tr_tr10 acs.acs_&acsyr._md_sum_tr_tr10 acs.acs_&acsyr._va_sum_tr_tr10 acs.acs_&acsyr._wv_sum_tr_tr10;
  %end;
%else %if %upcase( &source_geo ) = COUNTY %then %do;
  	 %ncdb_cnty;
     %let geo = county;
     %let geosuf = _cnty;
     %let ncdb00in = work.Ncdb_sum_was15_cnty;
	 %let ncdb10in = work.Ncdb_2010_sum_was15_cnty;
	 %let acsin = acs.acs_&acsyr._dc_sum_regcnt_regcnt acs.acs_&acsyr._md_sum_regcnt_regcnt acs.acs_&acsyr._va_sum_regcnt_regcnt acs.acs_&acsyr._wv_sum_regcnt_regcnt;
  %end;
%else %if %upcase( &source_geo ) = CITY %then %do;
     %let geo = city;
     %let geosuf = _city;
     %let ncdb00in = ncdb.Ncdb_sum_city;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_city;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_city;
  %end;
%else %if %upcase( &source_geo ) = WD12 %then %do;
     %let geo = ward2012;
     %let geosuf = _wd12;
     %let ncdb00in = ncdb.Ncdb_sum_wd12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_wd12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_wd12;
  %end;
%else %if %upcase( &source_geo ) = ANC12 %then %do;
     %let geo = anc2012;
     %let geosuf = _anc12;
     %let ncdb00in = ncdb.Ncdb_sum_anc12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_anc12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_anc12;
  %end;
 %else %if %upcase( &source_geo ) = CLTR00 %then %do;
     %let geo = cluster_tr2000;
     %let geosuf = _cltr00 ;
     %let ncdb00in = ncdb.Ncdb_sum_cltr00;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cltr00;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_cltr00;
  %end;
 %else %if %upcase( &source_geo ) = PSA12 %then %do;
     %let geo = psa2012;
     %let geosuf = _psa12;
     %let ncdb00in = ncdb.Ncdb_sum_psa12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_psa12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_psa12;
  %end;
 %else %if %upcase( &source_geo ) = ZIP %then %do;
     %let geo = zip;
     %let geosuf = _zip;
     %let ncdb00in = ncdb.Ncdb_sum_zip;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_zip;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_zip;
  %end;
 %else %if %upcase( &source_geo ) = CL17 %then %do;
     %let geo = cluster2017;
     %let geosuf = _cl17;
     %let ncdb00in = ncdb.Ncdb_sum_cl17;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cl17;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_cl17;
  %end;

%macro ncdbloop (ds,ncdbyr);

%macro dc_county (in);
data &in._cnty_long_allyr;
	set &in._city_long_allyr;
	county = "11001";
	drop city;
run;
%mend dc_county;
%dc_county (msf_sum);


data Ncdb_&ncdbyr._&topic.&geosuf.;

%if &ds. = ncdb %then %do;

	%if &ncdbyr. = 1990 %then %do;
	length timeframe $ 15;
	set &ncdb00in.;

	start_date = '01jan90'd;
	end_date = '31dec90'd;
	%end;

	%else %if &ncdbyr. = 2000 %then %do;
	length timeframe $ 15;
	set &ncdb00in.;

	start_date = '01jan00'd;
	end_date = '31dec00'd;
	%end;

	%else %if &ncdbyr. = 2010 %then %do;
	length timeframe $ 15;
	&ncdb10in.;

	start_date = '01jan10'd;
	end_date = '31dec10'd;
	%end;

	format start_date end_date date9. ;

	/* Unformatted tract ID */
	&geo._nf = &geo.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	/* County ID */
	ucounty=substr(geo2010,1,5);
	%end;

	/* timeframe */
	timeframe = "&ncdbyr" ;
%end;

%else %do;
	%let ncdbyr = &acsyr.;

	length timeframe $ 15;
	set &acsin.;

	&geo._nf = &geo.;

	timeframe = "&y_lbl." ;

	start_date = '01jan11'd;
	end_date = '31dec15'd;
	format start_date end_date date9. ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

%end;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);
	%end;

	%Pct_calc( var=Pct25andOverWoutHS, label=% persons without HS diploma, num=Pop25andOverWoutHS, den=Pop25andOverYears, years=1980 1990 2000 &acsyr. );
    

	keep &geo._nf &geo. start_date end_date timeframe
		 Pct25andOverWoutHS_&ncdbyr. ;

	rename 	Pct25andOverWoutHS_&ncdbyr. =	Pct25andOverWoutHS
;


%if &ds. = acs %then %do;

    %Moe_prop_a( var=Pct25andOverWoutHS_m_&acsyr., mult=100, num=Pop25andOverWoutHS_&acsyr., den=Pop25andOverYears_&acsyr., 
                       num_moe=mPop25andOverWoutHS_&acsyr., den_moe=mPop25andOverYears_&acsyr. );


	keep Pct25andOverWoutHS_m_&acsyr.;

	rename 	Pct25andOverWoutHS_m_&acsyr. = Pct25andOverWoutHS_m
			;

%end;


run;

%mend ncdbloop;

%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);



data alldata_&topic.&geosuf.;
	set msf_sum&geosuf._long_allyr (in=a) 
		Ncdb_acs_&topic.&geosuf. (in=b) 
		Ncdb_2000_&topic.&geosuf. (in=c) 
		Ncdb_1990_&topic.&geosuf. (in=d);

	if a and not (b and c and d) then do;
	Pct25andOverWoutHS = .x;
	Pct25andOverWoutHS_m =.x;
	end;

	if (c or d) and not b then do;
	Pct25andOverWoutHS_m =.x;
	end;

	else if b or c or d then do;
	aud =.x;
	aud_charter =.x;
	aud_dcps =.x;
	charter_present =.x;
	dcps_present =.x;
	school_present =.x;
	end;

run;

%suppress_lowpop (in_check = alldata_&topic.&geosuf.,
				  out_check = checked_&topic.&geosuf.);


data &topic.&geosuf.;
	set checked_&topic.&geosuf.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	format ucounty $profile_cnty.;
	%end;

	%else %if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;

	label 	Pct25andOverWoutHS = "% persons without HS diploma"
			Pct25andOverWoutHS_m = "% persons without HS diploma MOE"
			aud = "Total school enrollment"
			aud_charter = "Charter school enrollment"
			aud_dcps = "DCPS school enrollment" 
			charter_present = "Number of charter schools" 
			dcps_present = "Number of DCPS schools" 
			school_present = "Number of schools"
		  ;

	format Pct25andOverWoutHS Pct25andOverWoutHS_m aud aud_charter aud_dcps charter_present dcps_present school_present $profnum.;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "Pct25andOverWoutHS" then weborder = 1;
	else if name = "Pct25andOverWoutHS_m" then weborder = 2;
	else if name = "aud" then weborder = 3;
	else if name = "aud_charter" then weborder = 4;
	else if name = "aud_dcps" then weborder = 5;
	else if name = "school_present" then weborder = 6;
	else if name = "charter_present" then weborder = 7;
	else if name = "dcps_present" then weborder = 8;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&topic.\&topic.&geosuf._metadata.csv";
	proc print data =&topic.&geosuf._metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&topic.\&topic.&geosuf..csv";
	proc print data =&topic.&geosuf. noobs;
	run;
ods csv close;


%mend export_education;




/* End Macro */
