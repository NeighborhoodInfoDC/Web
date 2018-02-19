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




%macro export_safety (source_geo);

%let topic = safety ;

%if %upcase( &source_geo ) = GEO2010 %then %do;
     %let geo = geo2010;
     %let geosuf = _tr10;
     %let ncdb00in = ncdb.Ncdb_sum_was15_tr10;
	 %let ncdb10in = ncdb.Ncdb_2010_was15;
	 %let acsin = acs.acs_&acsyr._dc_sum_tr_tr10 acs.acs_&acsyr._md_sum_tr_tr10 acs.acs_&acsyr._va_sum_tr_tr10 acs.acs_&acsyr._wv_sum_tr_tr10;
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


data dcdata_&topic.&geosuf.;
	set crimes_sum&geosuf._long_allyr ;
run;


data &topic.&geosuf.;
	set dcdata_&topic.&geosuf.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	drop ucounty;
	%indc_flag (countyvar = ucounty);
	%end;
	%else %do;
	indc = 1;
	%end;

	label 	Crimes_pt1_violent_per1000 = "Violent Crimes (per 1,000 pop.)"
			Crimes_pt1_property_per1000 = "Property Crimes (per 1,000 pop.)"
		  ;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "Crimes_pt1_violent_per1000" then weborder = 1;
	else if name = "Crimes_pt1_property_per1000" then weborder = 2;
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


%mend export_safety;




/* End Macro */
