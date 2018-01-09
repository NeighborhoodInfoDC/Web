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

/*%macro export_housing (
datafile=,
metadatafile=
);*/

%include "&_dcdata_default_path.\realprop\prog\sales_forweb.sas";
%include "&_dcdata_default_path.\hmda\prog\hmda_forweb.sas";
%include "&_dcdata_default_path.\rod\prog\foreclosure_forweb.sas";

%let topic = housing ;

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

	%Pct_calc( var=PctSameHouse5YearsAgo, label=% same house 5 years ago, num=PopSameHouse5YearsAgo, den=Pop5andOverYears, years=&ncdbyr. );
    %Pct_calc( var=PctVacantHsgUnitsForRent, label=Rental vacancy rate (%), num=NumVacantHsgUnitsForRent, den=NumRenterHsgUnits, years=1980 1990 2000 &acsyr. )
    %Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=1980 1990 2000 &acsyr. )
    

	keep geo2010_nf geo2010 start_date end_date timeframe
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


data dcdata_&topic.;
	merge Sales_sum_tr10_long_allyr Hmda_sum_tr10_long_allyr Foreclosures_sum_tr10_long_allyr;
	by geo2010;
run;


data &topic._tr10;
	set Ncdb_acs_&topic. ncdb_2000_&topic. ncdb_1990_&topic. dcdata_&topic.;

	/* County ID */
	ucounty=substr(geo2010,1,5);
	drop ucounty;

	%indc_flag (countyvar = ucounty);

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


%mend export_housing;



/* End Macro */
