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

%macro export_connection (
datafile=,
metadatafile=
);

%let topic = connection ;

%macro ncdbloop (ds,ncdbyr);

data Ncdb_&ncdbyr._&topic.;

%if &ds. = ncdb %then %do;

	%if &ncdbyr. = 1990 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	start_date = '01jan90'd;
	end_date = '31dec90'd;
	%end;

	%else %if &ncdbyr. = 2000 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	start_date = '01jan00'd;
	end_date = '31dec00'd;
	%end;

	%else %if &ncdbyr. = 2010 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_2010_was15;

	start_date = '01jan10'd;
	end_date = '31dec10'd;
	%end;

	format start_date end_date date9. ;

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* County ID */
	ucounty=substr(geo2010,1,5);

	/* timeframe */
	timeframe = "&ncdbyr" ;
%end;

%else %do;

	set acs_all;
	%let ncdbyr = &acsyr.;

%end;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);

	%Pct_calc( var=PctHshldPhone, label=% HHs with a phone, num=NumHshldPhone, den=NumOccupiedHsgUnits, years=&ncdbyr. )
    %Pct_calc( var=PctHshldCar, label=% HHs with a car, num=NumHshldCar, den=NumOccupiedHsgUnits, years=&ncdbyr. )
    
	keep geo2010_nf geo2010 start_date end_date timeframe
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


data &topic._tr10;
	set Ncdb_acs_&topic. ncdb_2000_&topic.;

	/* County ID */
	ucounty=substr(geo2010,1,5);
	drop ucounty;

	%indc_flag (countyvar = ucounty);

	label 	PctHshldPhone = "% HHs with a phone"
			PctHshldCar = "% HHs with a car"
			PctHshldPhone_m = "% HHs with a phone MOE"
			PctHshldCar_m = "% HHs with a car MOE"
		  ;
run;


/* Create metadata for the dataset */
proc contents data = &topic._tr10 out = &topic._tr10_metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&metadatafile.";
	proc print data =&topic._tr10_metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&datafile.";
	proc print data =&topic._tr10 noobs;
	run;
ods csv close;


%mend export_connection;



/* End Macro */
