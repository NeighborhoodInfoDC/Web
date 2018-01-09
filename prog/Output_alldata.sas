/**************************************************************************
 Program:  Output_alldata
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = acs; /* Library of the summary data to be transposed */
%let outfolder = acs; /* Name of folder where output CSV will be saved */
%let acsyr = 2012_16; /* Year range for ACS data */
%let y_lbl = %sysfunc( translate( &acsyr., '-', '_' ) );
%let acs_infl_yr = 2016;

%let inc_dollar_yr = 2016;


/* Load ACS data for this update */
data acs_all;
	length timeframe $ 15;
	set acs.acs_&acsyr._dc_sum_tr_tr10 acs.acs_&acsyr._md_sum_tr_tr10 acs.acs_&acsyr._va_sum_tr_tr10 acs.acs_&acsyr._wv_sum_tr_tr10;

	/* Create county variable */
	ucounty=substr(geo2010,1,5);

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* ACS timeframe */
	timeframe = "&y_lbl." ;

	/* Populate start and end dates */
	start_date = '01jan11'd;
	end_date = '31dec15'd;
	format start_date end_date date9. ;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);
run;


%export_income (
datafile = income_tr10.csv, 
metadatafile = income_tr10_metadata.csv  );


%export_population (
datafile = population_tr10.csv, 
metadatafile = population_tr10_metadata.csv  );


%export_employment (
datafile = employment_tr10.csv, 
metadatafile = employment_tr10_metadata.csv  );


%export_housing (
datafile = housing_tr10.csv, 
metadatafile = housing_tr10_metadata.csv  );


%export_connection (
datafile = connection_tr10.csv, 
metadatafile = connection_tr10_metadata.csv  );


/* End of program */
