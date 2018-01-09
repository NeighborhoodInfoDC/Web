/**************************************************************************
 Program:  indc_flag
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Description: Macro to define counties in the Metro area
 Modifications: 

**************************************************************************/

%macro indc_flag (countyvar);

	if &countyvar. = "11001" then indc = 1;
		else indc = 0;
	label indc = "Flag for Census tract in Washington DC";

%mend indc_flag;


/*End Macro */
