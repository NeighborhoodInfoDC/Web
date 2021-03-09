/**************************************************************************
 Program:  export_connection
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_connection (source_geo);

%let topic = connection ;

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
	%geo_nf;

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
	set &acsin.;

	/* Unformatted tract ID */
	%geo_nf;

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

	/* Unformatted tract ID */
	%geo_nf;

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

	%Pct_calc( var=PctHshldPhone, label=% HHs with a phone, num=NumHshldPhone, den=NumOccupiedHsgUnits, years=&ncdbyr. )
    %Pct_calc( var=PctHshldCar, label=% HHs with a car, num=NumHshldCar, den=NumOccupiedHsgUnits, years=&ncdbyr. )
	%Pct_calc( var=PctBroadband, label=% HHs with broadband internet subscription, num=Numbroadband, den=Numhhdefined, years=&ncdbyr. )
	%Pct_calc( var=PctSmartphoneonly, label=% HHs with Smartphone and no other computer, num=NumSmartphoneonly, den=numhshlds, years=&ncdbyr. )
	%Pct_calc( var=PctNocomputer, label=% HHs with no computing devices, num=NumNocomputer, den=numhshlds, years=&ncdbyr. )
	%Pct_calc( var=Pctcellularonly, label=% HHs with cell data plan and no other internet, num=Numcellularonly, den=numhshlds, years=&ncdbyr. )
	%Pct_calc( var=Pctnointernet, label=% HHs with no internet access, num=Numnointernet, den=numhshlds, years=&ncdbyr. )

	
    
	keep &geo._nf &geo. start_date end_date timeframe
		 PctHshldPhone_&ncdbyr. PctHshldCar_&ncdbyr. PctBroadband_&ncdbyr.
		 PctNocomputer_&ncdbyr. Pctcellularonly_&ncdbyr. Pctnointernet_&ncdbyr.;

	rename 	PctHshldPhone_&ncdbyr. = PctHshldPhone
			PctHshldCar_&ncdbyr. = PctHshldCar
			PctBroadband_&ncdbyr. = PctBroadband
			PctNocomputer_&ncdbyr. = PctNocomputer
			Pctcellularonly_&ncdbyr. = Pctcellularonly
			Pctnointernet_&ncdbyr. = Pctnointernet
			;


%if &ds. = acs %then %do;

	%Moe_prop_a( var=PctHshldPhone_m_&ncdbyr., mult=100, num=NumHshldPhone_&ncdbyr., den=NumOccupiedHsgUnits_&ncdbyr., 
                       num_moe=mNumHshldPhone_&ncdbyr., den_moe=mNumOccupiedHsgUnits_&ncdbyr. );
    
    %Moe_prop_a( var=PctHshldCar_m_&ncdbyr., mult=100, num=NumHshldCar_&ncdbyr., den=NumOccupiedHsgUnits_&ncdbyr., 
                       num_moe=mNumHshldCar_&ncdbyr., den_moe=mNumOccupiedHsgUnits_&ncdbyr. );

	%Moe_prop_a( var=PctBroadband_m_&ncdbyr., mult=100, num=Numbroadband_&ncdbyr., den=Numhhdefined_&ncdbyr., 
                       num_moe=mNumbroadband_&ncdbyr., den_moe=mNumhhdefined_&ncdbyr. );

	%Moe_prop_a( var=PctNocomputer_m_&ncdbyr., mult=100, num=NumNocomputer_&ncdbyr., den=numhshlds_&ncdbyr., 
                       num_moe=mNumNocomputer_&ncdbyr., den_moe=mnumhshlds_&ncdbyr. );

	%Moe_prop_a( var=Pctcellularonly_m_&ncdbyr., mult=100, num=Numcellularonly_&ncdbyr., den=numhshlds_&ncdbyr., 
                       num_moe=mNumcellularonly_&ncdbyr., den_moe=mnumhshlds_&ncdbyr. );

	%Moe_prop_a( var=Pctnointernet_m_&ncdbyr., mult=100, num=Numnointernet_&ncdbyr., den=numhshlds_&ncdbyr., 
                       num_moe=mNumnointernet_&ncdbyr., den_moe=mnumhshlds_&ncdbyr. );


	keep PctHshldPhone_m_&ncdbyr. PctHshldCar_m_&ncdbyr. PctBroadband_m_&ncdbyr.
		 Pctnocomputer_m_&ncdbyr. Pctcellularonly_m_&ncdbyr. Pctnointernet_m_&ncdbyr.;

	rename 	PctHshldPhone_m_&ncdbyr. = PctHshldPhone_m
			PctHshldCar_m_&ncdbyr. = PctHshldCar_m
			PctBroadband_m_&ncdbyr. = PctBroadband_m
			PctNocomputer_m_&ncdbyr. = Pctnocomputer_m
			Pctcellularonly_m_&ncdbyr. = Pctcellularonly_m
			Pctnointernet_m_&ncdbyr. = Pctnointernet_m
			;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);
%ncdbloop (prevacs,prevacs);

data alldata_&topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. Ncdb_prevacs_&topic.&geosuf. Ncdb_2000_&topic.&geosuf. ;

	/* Flip Internet vars so all move in the same direction */
	if PctNocomputer ^=. then do;
	Pctcomputer = 100 - PctNocomputer;
	end;
	if Pctnointernet ^=.  then do;
	Pctinternet = 100 - Pctnointernet;
	end;

	Pctcomputer_m = PctNocomputer_m;
	Pctinternet_m = Pctnointernet_m;

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



	label 	PctHshldPhone = "% HHs with a phone"
			PctHshldCar = "% HHs with a car"
			PctBroadband = "% HHs with broadband internet subscription"
			Pctcomputer = "% HHs with computing devices"
			PctNocomputer ="% HHs with no computing devices"
			Pctcellularonly = "% HHs with cell data plan but no other internet"
			Pctinternet = "% HHs with internet access"
			Pctnointernet = "% HHs with no internet access"
			PctHshldPhone_m = "% HHs with a phone MOE"
			PctHshldCar_m = "% HHs with a car MOE"
			PctBroadband_m = "% HHs with broadband internet subscription MOE"
			Pctcomputer_m = "% HHs with computing devices MOE"
			PctNocomputer_m ="% HHs with no computing devices MOE"
			Pctcellularonly_m = "% HHs with cell data plan but no other internet MOE"
			Pctinternet_m = "% HHs with internet access MOE"
			Pctnointernet_m = "% HHs with no internet access MOE"
		  ;

	format PctHshldPhone PctHshldCar PctBroadband Pctcomputer Pctcellularonly Pctinternet 
			PctHshldPhone_m PctHshldCar_m PctBroadband_m Pctcomputer_m Pctcellularonly_m Pctinternet_m 
			profnum.;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "PctHshldCar" then weborder = 1;
	else if name = "PctHshldCar_m" then weborder = 2;
	else if name = "PctHshldPhone" then weborder = 3;
	else if name = "PctHshldPhone_m" then weborder = 4;
	else if name = "PctBroadband" then weborder = 5;
	else if name = "PctBroadband_m" then weborder = 6;
	else if name = "PctNocomputer" then weborder = 7;
	else if name = "PctNocomputer_m" then weborder = 8;
	else if name = "Pctcellularonly" then weborder = 9;
	else if name = "Pctcellularonly_m" then weborder = 10;
	else if name = "Pctnointernet" then weborder = 11;
	else if name = "Pctnointernet_m" then weborder = 12;

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


%mend export_connection;





/* End Macro */
