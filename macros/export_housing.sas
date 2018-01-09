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

	%Pct_calc( var=PctSameHouse5YearsAgo, label=% same house 5 years ago, num=PopSameHouse5YearsAgo, den=Pop5andOverYears, years=&ncdbyr. );
    %Pct_calc( var=PctVacantHsgUnitsForRent, label=Rental vacancy rate (%), num=NumVacantHsgUnitsForRent, den=NumRenterHsgUnits, years=1980 1990 2000 &acsyr. )
    %Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=1980 1990 2000 &acsyr. )
    

	keep &geo._nf &geo. start_date end_date timeframe
		 NumOccupiedHsgUnits_&ncdbyr. PctSameHouse5YearsAgo_&ncdbyr. PctVacantHsgUnitsForRent_&ncdbyr. PctOwnerOccupiedHsgUnits_&ncdbyr.;

	rename 	NumOccupiedHsgUnits_&ncdbyr. =	NumOccupiedHsgUnits
			PctSameHouse5YearsAgo_&ncdbyr. = PctSameHouse5YearsAgo
			PctVacantHsgUnitsForRent_&ncdbyr. = PctVacantHsgUnitsForRent
			PctOwnerOccupiedHsgUnits_&ncdbyr. = PctOwnerOccupiedHsgUnits
;


%if &ds. = acs %then %do;

    %Moe_prop_a( var=PctVacantHUForRent_m_&acsyr., mult=100, num=NumVacantHsgUnitsForRent_&acsyr., den=NumRenterHsgUnits_&acsyr., 
                       num_moe=mNumVacantHUForRent_&acsyr., den_moe=mNumRenterHsgUnits_&acsyr. );
    
    %Moe_prop_a( var=PctOwnerOccupiedHU_m_&acsyr., mult=100, num=NumOwnerOccupiedHsgUnits_&acsyr., den=NumOccupiedHsgUnits_&acsyr., 
                       num_moe=mNumOwnerOccupiedHU_&acsyr., den_moe=mNumOccupiedHsgUnits_&acsyr. );


	keep PctVacantHUForRent_m_&acsyr. PctOwnerOccupiedHU_m_&acsyr.;

	rename 	PctVacantHUForRent_m_&acsyr. = PctVacantHUForRent_m
			PctOwnerOccupiedHU_m_&acsyr. = PctOwnerOccupiedHU_m
			;

%end;


run;

%mend ncdbloop;

%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);


data dcdata_&topic.&geosuf.;
	merge Sales_sum&geosuf._long_allyr Hmda_sum&geosuf._long_allyr fcl&geosuf._long_allyr;
	by &geo.;
run;


data &topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. Ncdb_2000_&topic.&geosuf. Ncdb_1990_&topic.&geosuf. dcdata_&topic.&geosuf.;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	drop ucounty;
	%indc_flag (countyvar = ucounty);
	%end;
	%else %do;
	indc = 1;
	%end;

	label 	NumOccupiedHsgUnits = "Occupied housing units"
			PctSameHouse5YearsAgo = "% same house 5 years ago"
			PctVacantHsgUnitsForRent = "Rental vacancy rate (%)"
			PctOwnerOccupiedHsgUnits = "Homeownership rate (%)"
			PctVacantHUForRent_m = "Rental vacancy rate (%) MOE"
			PctOwnerOccupiedHU_m = "Homeownership rate (%) MOE"
			mprice_sf = "Single-Family Homes, Median sales price"
			sales_sf = "Single-Family Homes, Number of sales"
			MedianMrtgInc1_4m_adj = "MedianMrtgInc1_4m_adj"
			NumMrtgOrigHomePurchPerUnit = "Loans per 1,000 housing units" 
			PctSubprimeConvOrigHomePur = "% subprime loans" 
			forecl_ssl_1Kpcl_sf_condo = "Foreclosure notice rate per 1,000" 
			forecl_ssl_sf_condo = "SF homes/condos receiving foreclosure notice" 
			trustee_ssl_1Kpcl_sf_condo = "Trustee deed sale rate per 1,000" 
			trustee_ssl_sf_condo = "SF homes/condos receiving trustee deed sale notice"
		  ;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata noprint;
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
