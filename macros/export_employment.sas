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

%macro export_employment (source_geo);

%let topic = employment ;

%if %upcase( &source_geo ) = GEO2010 %then %do;
     %let geo = Geo2010;
     %let geosuf = _tr10;
     %let ncdb00in = ncdb.Ncdb_sum_was15_tr10;
	 %let ncdb10in = ncdb.Ncdb_2010_was15;
	 %let acsin = acs.acs_&acsyr._dc_sum_tr_tr10 acs.acs_&acsyr._md_sum_tr_tr10 acs.acs_&acsyr._va_sum_tr_tr10 acs.acs_&acsyr._wv_sum_tr_tr10;
	 %let prevacsin = acs.acs_&prevacsyr._dc_sum_tr_tr10 acs.acs_&prevacsyr._md_sum_tr_tr10 acs.acs_&prevacsyr._va_sum_tr_tr10 acs.acs_&prevacsyr._wv_sum_tr_tr10;
  %end;
%else %if %upcase( &source_geo ) = COUNTY %then %do;
  	 %ncdb_cnty;
     %let geo = County;
     %let geosuf = _cnty;
     %let ncdb00in = work.Ncdb_sum_was15_cnty;
	 %let ncdb10in = work.Ncdb_2010_sum_was15_cnty;
	 %let acsin = acs.acs_&acsyr._dc_sum_regcnt_regcnt acs.acs_&acsyr._md_sum_regcnt_regcnt acs.acs_&acsyr._va_sum_regcnt_regcnt acs.acs_&acsyr._wv_sum_regcnt_regcnt;
	 %let prevacsin = acs.acs_&prevacsyr._dc_sum_regcnt_regcnt acs.acs_&prevacsyr._md_sum_regcnt_regcnt acs.acs_&prevacsyr._va_sum_regcnt_regcnt acs.acs_&prevacsyr._wv_sum_regcnt_regcnt;
  %end;
%else %if %upcase( &source_geo ) = CITY %then %do;
     %let geo = City;
     %let geosuf = _city;
     %let ncdb00in = ncdb.Ncdb_sum_city;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_city;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_city;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_city;
  %end;
%else %if %upcase( &source_geo ) = WD12 %then %do;
     %let geo = Ward2012;
     %let geosuf = _wd12;
     %let ncdb00in = ncdb.Ncdb_sum_wd12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_wd12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_wd12 ;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_wd12;
  %end;
%else %if %upcase( &source_geo ) = ANC12 %then %do;
     %let geo = Anc2012;
     %let geosuf = _anc12;
     %let ncdb00in = ncdb.Ncdb_sum_anc12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_anc12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_anc12;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_anc12;
  %end;
 %else %if %upcase( &source_geo ) = CLTR00 %then %do;
     %let geo = Cluster_tr2000;
     %let geosuf = _cltr00 ;
     %let ncdb00in = ncdb.Ncdb_sum_cltr00;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cltr00;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_cltr00;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_cltr00;
  %end;
 %else %if %upcase( &source_geo ) = PSA12 %then %do;
     %let geo = Psa2012;
     %let geosuf = _psa12;
     %let ncdb00in = ncdb.Ncdb_sum_psa12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_psa12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_psa12;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_psa12;
  %end;
 %else %if %upcase( &source_geo ) = ZIP %then %do;
     %let geo = Zip;
     %let geosuf = _zip;
     %let ncdb00in = ncdb.Ncdb_sum_zip;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_zip;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_zip;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_zip;
  %end;
 %else %if %upcase( &source_geo ) = CL17 %then %do;
     %let geo = Cluster2017;
     %let geosuf = _cl17;
     %let ncdb00in = ncdb.Ncdb_sum_cl17;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cl17;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_cl17;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_cl17;
  %end;


%macro ncdbloop (ds,ncdbyr);

/* Need to rename variables in NDCB 2010 */
data rename_ncdb10;
	set &ncdb10in.;

	%if %upcase( &source_geo ) = COUNTY %then %do;
	TotPop_2010 = TRCTPOP1;
	PopUnder18Years_2010 = CHILD1N;
	Pop65andOverYears_2010 = OLD1N;
	PopWhiteNonHispBridge_2010 = SHRNHW1N;
	PopBlackNonHispBridge_2010 = SHRNHB1N;
	PopAsianPINonHispBridge_2010 = SHRNHA1N;
	PopWithRace_2010 = SHR1D;
	PopHisp_2010 = SHRHSP1N;
	%end;

run;


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

%else %if &ds. = prevacs %then %do;
	%let ncdbyr = &prevacsyr.;

	length timeframe $ 15;
	set &prevacsin.;

	&geo._nf = &geo.;

	timeframe = "&py_lbl." ;

	%let sy = %substr(&prevacsyr.,3,2);
	%let ey = %substr(&prevacsyr.,6,2);

	start_date = "01jan&sy."d;
	end_date = "31dec&ey."d;

	format start_date end_date date9. ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	%else %if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;
%end;

%else %do;
	%let ncdbyr = &acsyr.;

	length timeframe $ 15;
	set &acsin.;

	&geo._nf = &geo.;

	timeframe = "&y_lbl." ;

	%let sy = %substr(&acsyr.,3,2);
	%let ey = %substr(&acsyr.,6,2);

	start_date = "01jan&sy."d;
	end_date = "31dec&ey."d;
	format start_date end_date date9. ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	%else %if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;
%end;


	%if %upcase( &source_geo ) = GEO2010 %then %do;
	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);
	%end;

	%Pct_calc( var=PctUnemployed, label=Unemployment rate (%), num=PopUnemployed, den=PopInCivLaborForce, years= &ncdbyr. );
	%Pct_calc( var=Pct16andOverEmployed, label=% pop. 16+ yrs. employed, num=Pop16andOverEmployed, den=Pop16andOverYears, years=&ncdbyr. );
	


	keep &geo._nf &geo. start_date end_date timeframe
		 PctUnemployed_&ncdbyr. Pct16andOverEmployed_&ncdbyr.;

	rename 	PctUnemployed_&ncdbyr. = PctUnemployed
			Pct16andOverEmployed_&ncdbyr. = Pct16andOverEmployed
	;

%if &ds. = acs or &ds. = prevacs %then %do;

	%Moe_prop_a( var=PctUnemployed_m_&ncdbyr., mult=100, num=PopUnemployed_&ncdbyr., den=PopInCivLaborForce_&ncdbyr., 
                       num_moe=mPopUnemployed_&ncdbyr., den_moe=mPopInCivLaborForce_&ncdbyr. );
    
    %Moe_prop_a( var=Pct16andOverEmployed_m_&ncdbyr., mult=100, num=Pop16andOverEmployed_&ncdbyr., den=Pop16andOverYears_&ncdbyr., 
                       num_moe=mPop16andOverEmployed_&ncdbyr., den_moe=mPop16andOverYears_&ncdbyr. );


	keep PctUnemployed_m_&ncdbyr. Pct16andOverEmployed_m_&ncdbyr. ;

	rename 	PctUnemployed_m_&ncdbyr. = PctUnemployed_m
			Pct16andOverEmployed_m_&ncdbyr. = Pct16andOverEmployed_m ;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);
%ncdbloop (prevacs,prevacs);


data alldata_&topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. Ncdb_prevacs_&topic.&geosuf. Ncdb_2000_&topic.&geosuf. Ncdb_1990_&topic.&geosuf.;
run;

%suppress_lowpop (in_check = alldata_&topic.&geosuf.,
				  out_check = checked_&topic.&geosuf.);


data &topic.&geosuf.;
	set checked_&topic.&geosuf. 

		/* Lowercase the geo variable names */
		(rename=(&geo=%sysfunc(lowcase(&geo.))
		 &geo._nf=%sysfunc(lowcase(&geo._nf)))) ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	format ucounty $profile_cnty.;
	%indc_flag (countyvar = ucounty);
	%end;
	%else %if %upcase( &source_geo ) ^= COUNTY %then %do;
	indc = 1;
	%end;

	label PctUnemployed = "Unemployment rate (%)"
		  Pct16andOverEmployed = "% pop. 16+ yrs. employed"
		  PctUnemployed_m = "Unemployment rate (%) MOE"
		  Pct16andOverEmployed_m = "% pop. 16+ yrs. employed MOE"
		  ;

	format PctUnemployed Pct16andOverEmployed PctUnemployed_m Pct16andOverEmployed_m $profnum.;
run;

/* Lowercase the geo variable names 
proc datasets lib=work nolist;
	modify &topic.&geosuf.;
	rename &geo. = &lgeo.;
	rename &geo._nf = &lgeo._nf;
run;*/


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "PctUnemployed" then weborder = 1;
	else if name = "PctUnemployed_m" then weborder = 2;
	else if name = "Pct16andOverEmployed" then weborder = 3;
	else if name = "Pct16andOverEmployed_m" then weborder = 4;

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


%mend export_employment;



/* End Macro */
