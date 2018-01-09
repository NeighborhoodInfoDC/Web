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


/* Export population data */
%export_population (geo2010);
%export_population (city);
%export_population (wd12);
%export_population (anc12);
%export_population (cltr00);
%export_population (psa12);
%export_population (zip);


/* Export exmployment data */
%export_employment (geo2010);
%export_employment (city);
%export_employment (wd12);
%export_employment (anc12);
%export_employment (cltr00);
%export_employment (psa12);
%export_employment (zip);


/* Export housing data */
%include "&_dcdata_default_path.\realprop\prog\sales_forweb.sas";
%include "&_dcdata_default_path.\hmda\prog\hmda_forweb.sas";
%include "&_dcdata_default_path.\rod\prog\foreclosure_forweb.sas";

%export_housing (geo2010);
%export_housing (city);
%export_housing (wd12);
%export_housing (anc12);
%export_housing (cltr00);
%export_housing (psa12);
%export_housing (zip);


/* Export connection data */
%export_connection (geo2010);
%export_connection (city);
%export_connection (wd12);
%export_connection (anc12);
%export_connection (cltr00);
%export_connection (psa12);
%export_connection (zip);


/* End of program */
