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

  %let lgeo = %lowcase( &geo. );



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

	start_date = '01jan12'd;
	end_date = '31dec16'd;
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

	%Moe_prop_a( var=PctHshldPhone_m_&acsyr., mult=100, num=NumHshldPhone_&acsyr., den=NumOccupiedHsgUnits_&acsyr., 
                       num_moe=mNumHshldPhone_&acsyr., den_moe=mNumOccupiedHsgUnits_&acsyr. );
    
    %Moe_prop_a( var=PctHshldCar_m_&acsyr., mult=100, num=NumHshldCar_&acsyr., den=NumOccupiedHsgUnits_&acsyr., 
                       num_moe=mNumHshldCar_&acsyr., den_moe=mNumOccupiedHsgUnits_&acsyr. );

	%Moe_prop_a( var=PctBroadband_m_&acsyr., num=Numbroadband_&acsyr., den=Numhhdefined_&acsyr., 
                       num_moe=mNumbroadband_&acsyr., den_moe=mNumhhdefined_&acsyr. );

	%Moe_prop_a( var=PctNocomputer_m_&acsyr., num=NumNocomputer_&acsyr., den=numhshlds_&acsyr., 
                       num_moe=mNumNocomputer_&acsyr., den_moe=mnumhshlds_&acsyr. );

	%Moe_prop_a( var=Pctcellularonly_m_&acsyr., num=Numcellularonly_&acsyr., den=numhshlds_&acsyr., 
                       num_moe=mNumcellularonly_&acsyr., den_moe=mnumhshlds_&acsyr. );

	%Moe_prop_a( var=Pctnointernet_m_&acsyr., num=Numnointernet_&acsyr., den=numhshlds_&acsyr., 
                       num_moe=mNumnointernet_&acsyr., den_moe=mnumhshlds_&acsyr. );


	keep PctHshldPhone_m_&acsyr. PctHshldCar_m_&acsyr. PctBroadband_m_&acsyr.
		 PctNocomputer_m_&acsyr. Pctcellularonly_m_&acsyr. Pctnointernet_m_&acsyr.;

	rename 	PctHshldPhone_m_&acsyr. = PctHshldPhone_m
			PctHshldCar_m_&acsyr. = PctHshldCar_m
			PctBroadband_m_&acsyr. = PctBroadband_m
			PctNocomputer_m_&acsyr. = PctNocomputer_m
			Pctcellularonly_m_&acsyr. = Pctcellularonly_m
			Pctnointernet_m_&acsyr. = Pctnointernet_m
			;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);

data alldata_&topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. Ncdb_2000_&topic.&geosuf. ;
run;

%suppress_lowpop (in_check = alldata_&topic.&geosuf.,
				  out_check = checked_&topic.&geosuf.);


data &topic.&geosuf.;
	set checked_&topic.&geosuf.;

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
			PctHshldPhone_m = "% HHs with a phone MOE"
			PctHshldCar_m = "% HHs with a car MOE"
			PctBroadband_m = "% HHs with broadband internet subscription MOE"
			PctNocomputer = "% HHs with no computing devices"
			PctNocomputer_m = "% HHs with no computing devices MOE"
			Pctcellularonly = "% HHs with cell data plan and no other internet"
			Pctcellularonly_m = "% HHs with cell data plan and no other internet MOE"
			Pctnointernet = "% HHs with no internet access"
			Pctnointernet_m = "% HHs with no internet access MOE"

		  ;

	format PctHshldPhone PctHshldCar PctHshldPhone_m PctHshldCar_m PctBroadband PctBroadband_m $profnum.;
run;

/* Lowercase the geo variable names */
proc datasets lib=work nolist;
	modify &topic.&geosuf.;
	rename &geo. = &lgeo.;
	rename &geo._nf = &lgeo._nf;
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
