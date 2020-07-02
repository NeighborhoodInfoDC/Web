/**************************************************************************
 Program:  export_health
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_health (source_geo);

%let topic = health ;

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


%macro dc_county (in);
data &in._cnty_long_allyr;
	set &in._city_long_allyr;
	County = "11001";
	drop city city_nf;
	County_nf = county;
run;
%mend dc_county;
%dc_county (Births_sum);


/*data dcdata_&topic.&geosuf.;
	set births_sum&geosuf._long_allyr ;
run;*/

%suppress_lowpop (in_check = births_sum&geosuf._long_allyr,
				  out_check = dcdata_&topic.&geosuf.);


data &topic.&geosuf.;
	set dcdata_&topic.&geosuf.

	/* Lowercase the geo variable names */
	(rename=(&geo=%sysfunc(lowcase(&geo.))
		&geo._nf=%sysfunc(lowcase(&geo._nf)))) ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	format ucounty $profile_cnty.;
	%indc_flag (countyvar = ucounty);
	%end;
	%else %do;
	indc = 1;
	%end;

	label 	Pct_births_low_wt = "% low weight births (under 5.5 lbs)"
			Pct_births_teen = "% births to teen mothers"
		  ;

	format Pct_births_low_wt Pct_births_teen $profnum.;
run;

/* Lowercase the geo variable names 
proc datasets lib=work nolist;
	modify &topic.&geosuf.;
	%if %upcase( &source_geo ) ^= CL17 %then %do;
		rename &geo. = &lgeo.;
	%end;
	rename &geo._nf = &lgeo._nf;
run;*/


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "Pct_births_teen" then weborder = 1;
	else if name = "Pct_births_low_wt" then weborder = 2;
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


%mend export_health;




/* End Macro */
