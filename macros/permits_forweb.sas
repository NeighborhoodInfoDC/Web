/**************************************************************************
 Program:  permits_forweb
 Library:  Web
 Project:  Urban Greater DC
 Author:   Rob Pitingolo
 Created:  11/20/2019
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( DCRA )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = dcra; /* Library of the summary data to be transposed */
%let outfolder = housing; /* Name of folder where output CSV will be saved */
%let sumdata = permits_sum; /* Summary dataset name (without geo suffix) */
%let start = 2009; /* Start year */
%let end = 2018; /* End year */
%let keepvars = permits; /* Summary variables to keep and transpose */


/***** Update the web_varcreate marcro if you need to create final indicators for the website after transposing *****/

%macro web_varcreate;

label permits = "Total building permits "

%mend web_varcreate;



/**************** DO NOT UPDATE BELOW THIS LINE ****************/

%macro csv_create(geo);
			 
%web_transpose(&library., &outfolder., &sumdata., &geo., &start., &end., &keepvars. );

/* Load transposed data for all years, create indicators and labels for profiles */
data &sumdata._&geo._long_allyr;
	set &sumdata._&geo._long;
	%web_varcreate;
	label start_date = "Start Date"
		  end_date = "End Date"
		  timeframe = "Year of Data";
run;


/* Create metadata for the dataset */
proc contents data = &sumdata._&geo._long_allyr out = &sumdata._&geo._metadata noprint;
run;



%mend csv_create;
%csv_create (tr10);
%csv_create (anc12);
%csv_create (wd12);
%csv_create (city);
%csv_create (psa12);
%csv_create (zip);
%csv_create (cl17);
