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

	%Pct_calc( var=PctHshldPhone, label=% HHs with a phone, num=NumHshldPhone, den=NumOccupiedHsgUnits, years=&ncdbyr. )
    %Pct_calc( var=PctHshldCar, label=% HHs with a car, num=NumHshldCar, den=NumOccupiedHsgUnits, years=&ncdbyr. )
    
	keep &geo._nf &geo. start_date end_date timeframe
		 PctHshldPhone_&ncdbyr. PctHshldCar_&ncdbyr. ;

	rename 	PctHshldPhone_&ncdbyr. = PctHshldPhone
			PctHshldCar_&ncdbyr. = PctHshldCar
;


%if &ds. = acs %then %do;

	%Moe_prop_a( var=PctHshldPhone_m_&acsyr., mult=100, num=NumHshldPhone_&acsyr., den=NumOccupiedHsgUnits_&acsyr., 
                       num_moe=mNumHshldPhone_&acsyr., den_moe=mNumOccupiedHsgUnits_&acsyr. );
    
    %Moe_prop_a( var=PctHshldCar_m_&acsyr., mult=100, num=NumHshldCar_&acsyr., den=NumOccupiedHsgUnits_&acsyr., 
                       num_moe=mNumHshldCar_&acsyr., den_moe=mNumOccupiedHsgUnits_&acsyr. );


	keep PctHshldPhone_m_&acsyr. PctHshldCar_m_&acsyr.;

	rename 	PctHshldPhone_m_&acsyr. = PctHshldPhone_m
			PctHshldCar_m_&acsyr. = PctHshldCar_m
			;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);


data &topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. Ncdb_2000_&topic.&geosuf. ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	drop ucounty;
	%indc_flag (countyvar = ucounty);
	%end;
	%else %do;
	indc = 1;
	%end;

	label 	PctHshldPhone = "% HHs with a phone"
			PctHshldCar = "% HHs with a car"
			PctHshldPhone_m = "% HHs with a phone MOE"
			PctHshldCar_m = "% HHs with a car MOE"
		  ;
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
