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

/* Export housing data */
%export_housing (geo2010);
%export_housing (city);
%export_housing (wd12);
%export_housing (anc12);
%export_housing (cltr00);
%export_housing (psa12);
%export_housing (zip);



/* End of program */
