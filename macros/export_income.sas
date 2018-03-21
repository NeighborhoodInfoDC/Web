/**************************************************************************
 Program:  export_income
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_income (source_geo);

%let topic = income ;

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
	drop city city_nf;
	county_nf = county;
run;
%mend dc_county;
%dc_county (Tanf_sum);
%dc_county (FS_sum);


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

	%Pct_calc( var=PctPoorPersons, label=Poverty rate (%), num=PopPoorPersons, den=PersonsPovertyDefined, years= &ncdbyr. );
	%Pct_calc( var=PctPoorChildren, label=% children in poverty, num=PopPoorChildren, den=ChildrenPovertyDefined, years=&ncdbyr. );
	%Pct_calc( var=PctPoorElderly, label=% seniors in poverty, num=PopPoorElderly, den=ElderlyPovertyDefined, years=&ncdbyr. );
	%Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=&ncdbyr. );
	%dollar_convert( AvgFamilyIncome_&ncdbyr., AvgFamilyIncAdj_&ncdbyr., &acs_infl_yr., &inc_dollar_yr. );

	keep &geo._nf &geo. start_date end_date timeframe
		 PctPoorPersons_&ncdbyr. PctPoorChildren_&ncdbyr. PctPoorElderly_&ncdbyr. AvgFamilyIncAdj_&ncdbyr. 
	     PctPoorPersons_m_&ncdbyr. PctPoorChildren_m_&ncdbyr. PctPoorElderly_m_&ncdbyr. AvgFamilyIncAdj_m_&ncdbyr. ;

	rename PctPoorPersons_&ncdbyr. = PctPoorPersons
	 	   PctPoorChildren_&ncdbyr. = PctPoorChildren
		   PctPoorElderly_&ncdbyr. = PctPoorElderly
		   AvgFamilyIncAdj_&ncdbyr. = AvgFamilyIncAdj
		   ;

	%if &ds. = acs %then %do;
	%Moe_prop_a( var=PctPoorPersons_m_&acsyr., mult=100, num=PopPoorPersons_&acsyr., den=PersonsPovertyDefined_&acsyr., 
                       num_moe=mPopPoorPersons_&acsyr., den_moe=mPersonsPovertyDefined_&acsyr., label_moe = Poverty rate (%) &y_lbl. MOE );
    %Moe_prop_a( var=PctPoorChildren_m_&acsyr., mult=100, num=PopPoorChildren_&acsyr., den=ChildrenPovertyDefined_&acsyr., 
                       num_moe=mPopPoorChildren_&acsyr., den_moe=mChildrenPovertyDefined_&acsyr., label_moe = % children in poverty &y_lbl. MOE );     
    %Moe_prop_a( var=PctPoorElderly_m_&acsyr., mult=100, num=PopPoorElderly_&acsyr., den=ElderlyPovertyDefined_&acsyr., 
                       num_moe=mPopPoorElderly_&acsyr., den_moe=mElderlyPovertyDefined_&acsyr., label_moe = % seniors in poverty &y_lbl. MOE );
	AvgFamilyIncome_m_&acsyr. = 
      %Moe_ratio( num=AggFamilyIncome_&acsyr., den=NumFamilies_&acsyr., 
                  num_moe=mAggFamilyIncome_&acsyr., den_moe=mNumFamilies_&acsyr. );

	%dollar_convert( AvgFamilyIncome_m_&acsyr., AvgFamilyIncAdj_m_&acsyr., &acs_infl_yr., &inc_dollar_yr );

	keep PctPoorPersons_m_&acsyr. PctPoorChildren_m_&acsyr. PctPoorElderly_m_&acsyr. AvgFamilyIncAdj_m_&acsyr. ;

	rename PctPoorPersons_m_&acsyr. = PctPoorPersons_m
		   PctPoorChildren_m_&acsyr. = PctPoorChildren_m
		   PctPoorElderly_m_&acsyr. = PctPoorElderly_m
		   AvgFamilyIncAdj_m_&acsyr. = AvgFamilyIncAdj_m
		   ;

%end;


run;

%mend ncdbloop;

%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);


data acs_all&geosuf.;
	set &acsin.; 
run;


data ch_&topic.&geosuf.;
	merge acs_all&geosuf. &ncdb00in.;
	by &geo.;

	%Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=1990 2000 &acsyr. )

	%dollar_convert( AvgFamilyIncome_1990, AvgFamilyIncAdj_1990, 1990, &inc_dollar_yr. );
	%dollar_convert( AvgFamilyIncome_2000, AvgFamilyIncAdj_2000, 2000, &inc_dollar_yr. );
	%dollar_convert( AvgFamilyIncome_&acsyr., AvgFamilyIncAdj_&acsyr., &acs_infl_yr., &inc_dollar_yr. );

	 if AvgFamilyIncAdj_1990 > 0 then PctChgAvgFamilyIncAdj_1990_2000 = %pctchg( AvgFamilyIncAdj_1990, AvgFamilyIncAdj_2000 );
	 if AvgFamilyIncAdj_2000 > 0 then PctChgAvgFamilyIncA_2000_&acsyr. = %pctchg( AvgFamilyIncAdj_2000, AvgFamilyIncAdj_&acsyr. );

run;


data ch_&topic.&geosuf._1990_2000;
	length timeframe $ 15;
	set ch_&topic.&geosuf.;

	/* Unformatted tract ID */
	&geo._nf = &geo.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	format ucounty $profile_cnty.;
	%end;

	/* ACS timeframe */
	timeframe = "1990 to 2000" ;

	/* Populate start and end dates */
	start_date = '01jan90'd;
	end_date = '31dec00'd;
	format start_date end_date date9. ;

	PctChgAvgFamilyIncAdj = PctChgAvgFamilyIncAdj_1990_2000;
	keep &geo._nf &geo. start_date end_date timeframe PctChgAvgFamilyIncAdj;
run;


data ch_&topic.&geosuf._2000_ACS;
	length timeframe $ 15;
	set ch_&topic.&geosuf.;

	/* Unformatted tract ID */
	&geo._nf = &geo.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	/* ACS timeframe */
	
	timeframe = "2000 to 2012-16" ;

	/* Populate start and end dates */
	start_date = '01jan00'd;
	end_date = '31dec16'd;
	format start_date end_date date9. ;


	PctChgAvgFamilyIncAdj = PctChgAvgFamilyIncA_2000_&acsyr.;
	keep &geo._nf &geo. start_date end_date timeframe PctChgAvgFamilyIncAdj;
run;


proc sort data = Tanf_sum&geosuf._long_allyr; by &geo._nf; run;
proc sort data = Fs_sum&geosuf._long_allyr; by &geo._nf; run;

data tanf_fs&geosuf.;
	merge Tanf_sum&geosuf._long_allyr Fs_sum&geosuf._long_allyr;
	by &geo._nf;
run;

data alldata_&topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. (in=a) 
		Ncdb_2000_&topic.&geosuf. (in=b) 
		Ncdb_1990_&topic.&geosuf. (in=c) 
		ch_&topic.&geosuf._2000_ACS (in=d) 
		ch_&topic.&geosuf._1990_2000 (in=e) 
		tanf_fs&geosuf. (in=f);

	if f then do;
	PctPoorPersons =.x;
	PctPoorPersons_m = .x;
	PctPoorChildren = .x;
	PctPoorChildren_m = .x;
	PctPoorElderly = .x;
	PctPoorElderly_m = .x;
	AvgFamilyIncAdj = .x;
	AvgFamilyIncAdj_m = .x;
	PctChgAvgFamilyIncAdj = .x;
	end;

	else if d or e then do;
	PctPoorPersons =.x;
	PctPoorPersons_m = .x;
	PctPoorChildren = .x;
	PctPoorChildren_m = .x;
	PctPoorElderly = .x;
	PctPoorElderly_m = .x;
	AvgFamilyIncAdj = .x;
	AvgFamilyIncAdj_m = .x;
	Tanf_client = .x;
	fs_client = .x;
	end;

	else if a or b or c then do;
	PctChgAvgFamilyIncAdj = .x;
	Tanf_client = .x;
	fs_client = .x;
	end;

run;

%suppress_lowpop (in_check = alldata_&topic.&geosuf.,
				  out_check = checked_&topic.&geosuf.);


data &topic.&geosuf.;
	set checked_&topic.&geosuf.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	format ucounty $profile_cnty.;
	%define_dcmetro (countyvar = ucounty);
	%end;

	%else %if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;

	label PctPoorPersons = "Poverty rate (%)"
		  PctPoorChildren = "% children in poverty"
		  PctPoorElderly = "% seniors in poverty"
		  AvgFamilyIncAdj = "Avg. family income"
		  PctPoorPersons_m = "Poverty rate (%) MOE"
		  PctPoorChildren_m = "% children in poverty MOE"
		  PctPoorElderly_m = "% seniors in poverty MOE"
		  AvgFamilyIncAdj_m = "AvgFamilyIncAdj MOE"
		  PctChgAvgFamilyIncAdj = "% change in avg. family income"
		  ;

	format PctPoorPersons PctPoorChildren PctPoorElderly AvgFamilyIncAdj 
		   PctPoorPersons_m PctPoorChildren_m PctPoorElderly_m AvgFamilyIncAdj_m PctChgAvgFamilyIncAdj 
	       Fs_client Tanf_client $profnum.;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "PctPoorPersons" then weborder = 1;
	else if name = "PctPoorPersons_m" then weborder = 2;
	else if name = "PctPoorChildren" then weborder = 3;
	else if name = "PctPoorChildren_m" then weborder = 4;
	else if name = "PctPoorElderly" then weborder = 5;
	else if name = "PctPoorElderly_m" then weborder = 6;
	else if name = "AvgFamilyIncAdj" then weborder = 7;
	else if name = "AvgFamilyIncAdj_m" then weborder = 8;
	else if name = "PctChgAvgFamilyIncAdj" then weborder = 9;

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

%mend export_income;


/* End Macro */
