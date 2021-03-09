/**************************************************************************
 Program:  geo_nf
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Description: Macro to create the _nf version of the geography. This is needed
			  to match exactly to the shapefile in the data explorer. 
 Modifications: 

**************************************************************************/

%macro geo_nf ();

	%if %upcase( &source_geo ) = CL17 %then %do;
	cs = cluster2017+0;
	cc = put(cs,2.);
	cluster2017_nf = "Cluster "|| trim(left(cc));
	drop cs cc;
	%end;

	%else %do;
	&geo._nf = &geo.;
	%end;

%mend geo_nf;


/*End Macro */
