/**************************************************************************
 Program:  export_housing
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_housing (source_geo);

%let topic = housing ;

/* Labels for ACS years */
%let y_lbl = %sysfunc( translate( &acsyr., '-', '_' ) );
%let py_lbl = %sysfunc( translate( &prevacsyr., '-', '_' ) );

** Last year of ACS data for inflation adjustment **;
%let last_acs = %substr(&acsyr.,6,2);
%let acs_infl_yr = 20&last_acs. ;

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

  %let lgeo = %lowcase( &geo. );


/* Need to rename variables in NDCB 2010 */
data rename_ncdb10;
	set &ncdb10in.;

	%if %upcase( &source_geo ) = COUNTY or
	    %upcase( &source_geo ) = GEO2010 %then %do;
	NumOccupiedHsgUnits = OCCHU1;
	%end;
run;


 /* Macro to create a _cnty suffix file for each _city dc file */
%macro dc_county (in);
data &in._cnty_long_allyr;
	set &in._city_long_allyr;
	county = "11001";
	drop city;
run;
%mend dc_county;
%dc_county (sales_sum);
%dc_county (hmda_sum);
%dc_county (fcl);



%macro ncdbloop (ds,ncdbyr);

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
	set rename_ncdb10;

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

%end;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	%else %if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;

	%Pct_calc( var=PctSameHouse5YearsAgo, label=% same house 5 years ago, num=PopSameHouse5YearsAgo, den=Pop5andOverYears, years=&ncdbyr. );
    %Pct_calc( var=PctVacantHsgUnitsForRent, label=Rental vacancy rate (%), num=NumVacantHsgUnitsForRent, den=NumRenterHsgUnits, years=1980 1990 2000 &acsyr. )
    %Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=1980 1990 2000 &acsyr. )
    
%if &ncdbyr. = 2010 %then %do;
	keep &geo._nf &geo. start_date end_date timeframe NumOccupiedHsgUnits_&ncdbyr. ;
	rename 	NumOccupiedHsgUnits_&ncdbyr. =	NumOccupiedHsgUnits;
%end;

%else %do;
	keep &geo._nf &geo. start_date end_date timeframe NumOccupiedHsgUnits_&ncdbyr.
		 PctSameHouse5YearsAgo_&ncdbyr. PctVacantHsgUnitsForRent_&ncdbyr. PctOwnerOccupiedHsgUnits_&ncdbyr. ;

	rename 	PctSameHouse5YearsAgo_&ncdbyr. = PctSameHouse5YearsAgo
			PctVacantHsgUnitsForRent_&ncdbyr. = PctVacantHsgUnitsForRent
			PctOwnerOccupiedHsgUnits_&ncdbyr. = PctOwnerOccupiedHsgUnits
			NumOccupiedHsgUnits_&ncdbyr. =	NumOccupiedHsgUnits;
%end;

%if &ds. = acs or &ds. = prevacs %then %do;

    %Moe_prop_a( var=PctVacantHUForRent_m_&ncdbyr., mult=100, num=NumVacantHsgUnitsForRent_&ncdbyr., den=NumRenterHsgUnits_&ncdbyr., 
                       num_moe=mNumVacantHUForRent_&ncdbyr., den_moe=mNumRenterHsgUnits_&ncdbyr. );
    
    %Moe_prop_a( var=PctOwnerOccupiedHU_m_&ncdbyr., mult=100, num=NumOwnerOccupiedHsgUnits_&ncdbyr., den=NumOccupiedHsgUnits_&ncdbyr., 
                       num_moe=mNumOwnerOccupiedHU_&ncdbyr., den_moe=mNumOccupiedHsgUnits_&ncdbyr. );


	keep PctVacantHUForRent_m_&ncdbyr. PctOwnerOccupiedHU_m_&ncdbyr. mNumOccupiedHsgUnits_&ncdbyr.;

	rename 	PctVacantHUForRent_m_&ncdbyr. = PctVacantHUForRent_m
			PctOwnerOccupiedHU_m_&ncdbyr. = PctOwnerOccupiedHU_m
			mNumOccupiedHsgUnits_&ncdbyr. = NumOccupiedHsgUnits_m
			;

%end;


run;

%mend ncdbloop;

%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (ncdb,2010);
%ncdbloop (acs,acs);
%ncdbloop (prevacs,prevacs);


data dcdata_&topic.&geosuf.;
	merge Sales_sum&geosuf._long_allyr Hmda_sum&geosuf._long_allyr fcl&geosuf._long_allyr Permits_sum&geosuf._long_allyr;
	by &geo.;
	&geo._nf = &geo.;
run;


data price_change&geosuf.;
	%if %upcase( &source_geo ) = COUNTY %then %do;
	set realprop.sales_sum_city;
	county = "11001";
	drop city;
	%end;
	%else %do;
	set realprop.sales_sum&geosuf.;
	%end;

	%let rsales_end_yr = 2016;

	%let rsales_b1yr = %eval( &rsales_end_yr - 1 );
    %let rsales_b5yr = %eval( &rsales_end_yr - 5 );
    %let rsales_b10yr = %eval( &rsales_end_yr - 10 );
    
    PctAnnChgRMPriceSf_1yr = 100 * %annchg( r_mprice_sf_&rsales_b1yr, r_mprice_sf_&rsales_end_yr, 1 );
    PctAnnChgRMPriceSf_5yr = 100 * %annchg( r_mprice_sf_&rsales_b5yr, r_mprice_sf_&rsales_end_yr, 5 );
    PctAnnChgRMPriceSf_10yr = 100 * %annchg( r_mprice_sf_&rsales_b10yr, r_mprice_sf_&rsales_end_yr, 10 );

    if PctAnnChgRMPriceSf_1yr = . then PctAnnChgRMPriceSf_1yr = .i;
    if PctAnnChgRMPriceSf_5yr = . then PctAnnChgRMPriceSf_5yr = .i;
    if PctAnnChgRMPriceSf_10yr = . then PctAnnChgRMPriceSf_10yr = .i;
run;

%macro priceloop (y,from,to,f,t);
data PctAnnChgRMPriceSf_&y.&geosuf.;
	length timeframe $ 15;
	set price_change&geosuf.;

	&geo._nf = &geo.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;
	
	timeframe = "&to." ;

	/* Populate start and end dates */
	start_date = "01jan&f."d;
	end_date = "31dec&t."d;
	format start_date end_date date9. ;

	keep &geo._nf &geo. start_date end_date timeframe PctAnnChgRMPriceSf_&y.yr;
%mend priceloop;
%priceloop(1,2015,2016,15,16);
%priceloop(5,2011,2016,11,16);
%priceloop(10,2006,2016,06,16);


data alldata_&topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. (in=a)
		Ncdb_prevacs_&topic.&geosuf. (in=b)
		Ncdb_2010_&topic.&geosuf. (in=c) 
		Ncdb_2000_&topic.&geosuf. (in=d) 
		Ncdb_1990_&topic.&geosuf. (in=e) 
		dcdata_&topic.&geosuf. (in=f) 
		PctAnnChgRMPriceSf_1&geosuf. (in=g) 
		PctAnnChgRMPriceSf_5&geosuf. (in=h) 
		PctAnnChgRMPriceSf_10&geosuf. (in=i);

	if a or b or c or d or e then do;
	mprice_sf = .x;
	sales_sf = .x;
	MedianMrtgInc1_4m_adj = .x;
	NumMrtgOrigHomePurchPerUnit = .x;
	PctSubprimeConvOrigHomePur = .x;
	forecl_ssl_1Kpcl_sf_condo = .x;
	forecl_ssl_sf_condo = .x;
	trustee_ssl_1Kpcl_sf_condo = .x;
	trustee_ssl_sf_condo = .x;
	PctAnnChgRMPriceSf_1yr = .x;
	PctAnnChgRMPriceSf_5yr = .x;
	PctAnnChgRMPriceSf_10yr = .x;
	end;

	else if f or g or h or i then do;
	NumOccupiedHsgUnits = .x;
	PctSameHouse5YearsAgo = .x;
	PctVacantHsgUnitsForRent = .x;
	PctOwnerOccupiedHsgUnits = .x;
	PctVacantHUForRent_m = .x;
	PctOwnerOccupiedHU_m = .x;
	end;

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

	label 	NumOccupiedHsgUnits = "Occupied housing units"
			PctSameHouse5YearsAgo = "% same house 5 years ago"
			PctVacantHsgUnitsForRent = "Rental vacancy rate (%)"
			PctOwnerOccupiedHsgUnits = "Homeownership rate (%)"
			NumOccupiedHsgUnits_m = "Occupied housing units MOE"
			PctVacantHUForRent_m = "Rental vacancy rate (%) MOE"
			PctOwnerOccupiedHU_m = "Homeownership rate (%) MOE"
			mprice_sf = "Single-Family Homes, Median sales price"
			sales_sf = "Single-Family Homes, Number of sales"
			MedianMrtgInc1_4m_adj = "Median borrower income"
			NumMrtgOrigHomePurchPerUnit = "Loans per 1,000 housing units" 
			PctSubprimeConvOrigHomePur = "% subprime loans" 
			forecl_ssl_1Kpcl_sf_condo = "Foreclosure notice rate per 1,000" 
			forecl_ssl_sf_condo = "SF homes/condos receiving foreclosure notice" 
			trustee_ssl_1Kpcl_sf_condo = "Trustee deed sale rate per 1,000" 
			trustee_ssl_sf_condo = "SF homes/condos receiving trustee deed sale notice"
			PctAnnChgRMPriceSf_1yr = "% annual change median price past 1 year"
			PctAnnChgRMPriceSf_5yr = "% annual change median price past 5 years"
			PctAnnChgRMPriceSf_10yr = "% annual change median price past 10 years"
		  ;

	format NumOccupiedHsgUnits PctSameHouse5YearsAgo PctVacantHsgUnitsForRent PctOwnerOccupiedHsgUnits PctVacantHUForRent_m
		   PctOwnerOccupiedHU_m NumOccupiedHsgUnits_m mprice_sf sales_sf MedianMrtgInc1_4m_adj 
		   NumMrtgOrigHomePurchPerUnit PctSubprimeConvOrigHomePur 
		   forecl_ssl_1Kpcl_sf_condo forecl_ssl_sf_condo trustee_ssl_1Kpcl_sf_condo trustee_ssl_sf_condo 
	       PctAnnChgRMPriceSf_1yr PctAnnChgRMPriceSf_5yr PctAnnChgRMPriceSf_10yr permits $profnum.;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "NumOccupiedHsgUnits" then weborder = 1;
	else if name = "PctSameHouse5YearsAgo" then weborder = 2;
	else if name = "PctVacantHsgUnitsForRent" then weborder = 3;
	else if name = "NumOccupiedHsgUnits_m" then weborder = 4;
	else if name = "PctVacantHUForRent_m" then weborder = 5;
	else if name = "PctOwnerOccupiedHsgUnits" then weborder = 6;
	else if name = "PctOwnerOccupiedHU_m" then weborder = 7;
	else if name = "sales_sf" then weborder = 8;
	else if name = "mprice_sf" then weborder = 9;
	else if name = "PctAnnChgRMPriceSf_10yr" then weborder = 10;
	else if name = "PctAnnChgRMPriceSf_5yr" then weborder = 11;
	else if name = "PctAnnChgRMPriceSf_1yr" then weborder = 12;
	else if name = "NumMrtgOrigHomePurchPerUnit" then weborder = 13;
	else if name = "MedianMrtgInc1_4m_adj" then weborder = 14;
	else if name = "PctSubprimeConvOrigHomePur" then weborder = 15;
	else if name = "forecl_ssl_sf_condo" then weborder = 16;
	else if name = "forecl_ssl_1Kpcl_sf_condo" then weborder = 17;
	else if name = "trustee_ssl_sf_condo" then weborder = 18;
	else if name = "trustee_ssl_1Kpcl_sf_condo" then weborder = 19;
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


%mend export_housing;




/* End Macro */
