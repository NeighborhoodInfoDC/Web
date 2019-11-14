/**************************************************************************
 Program:  fix_cl17_fmt
 Library:  Web
 Project:  Urban Greater DC
 Author:   Rob Pitingolo
 Created:  11/14/19
 Version:  SAS 9.4
 Environment:  Windows
 Description: The cluster2017 ID needs to be formatted in a specific way for
			  the data explorer. 
 Modifications: 

**************************************************************************/

%macro fix_cl17_fmt;

	nv = &sortvar. + 0;
	cv = put(nv, 2. -l);
	&sortvar._nf = "Cluster" || " " || cv ;
	drop nv cv;

%mend fix_cl17_fmt;


/*End Macro */
