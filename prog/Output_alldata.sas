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

%let acsyr = 2012_16; /* Year range for ACS data */
%let y_lbl = %sysfunc( translate( &acsyr., '-', '_' ) );

** Last year of ACS data for inflation adjustment **;
%let acs_infl_yr = 2016;

** Inflation base year **;
%let inc_dollar_yr = 2016;


** Format for final output data **;
 proc format;
    picture profnum (default=12 round)
      -9999999999, .i = 'i' (noedit)
      -9999999998, .s = 's' (noedit)
      -999999999 - -10 = '000,000,009' (prefix='-')
      -10 <-< 0 = '009.9' (prefix='-')
       0   -<10 = '009.9'
      10 - high = '000,000,009' ;
  run;


/* Export population data */
%export_population (geo2010);
%export_population (county);
%export_population (city);
%export_population (wd12);
%export_population (anc12);
%export_population (psa12);
%export_population (zip);
%export_population (cl17);


/* Export exmployment data */
%export_employment (geo2010);
%export_employment (county);
%export_employment (city);
%export_employment (wd12);
%export_employment (anc12);
%export_employment (psa12);
%export_employment (zip);
%export_employment (cl17);


/* Export housing data */
%include "&_dcdata_default_path.\realprop\prog\sales_forweb.sas";
%include "&_dcdata_default_path.\hmda\prog\hmda_forweb.sas";
%include "&_dcdata_default_path.\rod\prog\foreclosure_forweb.sas";

%export_housing (geo2010);
%export_housing (county);
%export_housing (city);
%export_housing (wd12);
%export_housing (anc12);
%export_housing (psa12);
%export_housing (zip);
%export_housing (cl17);


/* Export connection data */
%export_connection (geo2010);
%export_connection (county);
%export_connection (city);
%export_connection (wd12);
%export_connection (anc12);
%export_connection (psa12);
%export_connection (zip);
%export_connection (cl17);


/* Export income data */
%include "&_dcdata_default_path.\tanf\prog\TANF_forweb.sas";
%include "&_dcdata_default_path.\tanf\prog\FS_forweb.sas";
%export_income (geo2010);
%export_income (county);
%export_income (city);
%export_income (wd12);
%export_income (anc12);
%export_income (psa12);
%export_income (zip);
%export_income (cl17);


/* Export education data */
%include "&_dcdata_default_path.\Schools\Prog\Schools_forweb.sas";
%export_education (geo2010);
%export_education (county);
%export_education (city);
%export_education (wd12);
%export_education (anc12);
%export_education (psa12);
%export_education (zip);
%export_education (cl17);


/* Export health data */
%include "&_dcdata_default_path.\Vital\Prog\Births_forweb.sas";
%export_health (geo2010);
%export_health (county);
%export_health (city);
%export_health (wd12);
%export_health (anc12);
%export_health (psa12);
%export_health (zip);
%export_health (cl17);


/* Export safety data */
%include "&_dcdata_default_path.\Police\Prog\Crimes_forweb.sas";
%export_safety (geo2010);
%export_safety (city);
%export_safety (county);
%export_safety (wd12);
%export_safety (anc12);
%export_safety (psa12);
%export_safety (zip);
%export_safety (cl17);


/* End of program */
