/**************************************************************************
 Program:  housing_unit_count
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/18/9
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro housing_unit_count (source_geo);


%if %upcase( &source_geo ) = GEO2010 %then %do;
     %let sortvar = GEO2010;
     %let TypeOfDat = TR10;
     %let geosuf = _tr10;
     %let ncdb00in = ncdb.Ncdb_sum_was15_tr10;
	 %let ncdb10in = ncdb.Ncdb_2010_was15;
  %end;
%else %if %upcase( &source_geo ) = COUNTY %then %do;
  	 %ncdb_cnty;
     %let sortvar = COUNTY;
     %let TypeOfDat = CNTY;
     %let geosuf = _cnty;
     %let ncdb00in = work.Ncdb_sum_was15_cnty;
	 %let ncdb10in = work.Ncdb_2010_sum_was15_cnty;
  %end;
%else %if %upcase( &source_geo ) = CITY %then %do;
     %let sortvar = CITY;
     %let TypeOfDat = CITY;
     %let geosuf = _city;
     %let ncdb00in = ncdb.Ncdb_sum_city;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_city;
  %end;
%else %if %upcase( &source_geo ) = WD12 %then %do;
     %let sortvar = WARD2012;
     %let TypeOfDat = WD12;
     %let geosuf = _wd12;
     %let ncdb00in = ncdb.Ncdb_sum_wd12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_wd12;
  %end;
%else %if %upcase( &source_geo ) = ANC12 %then %do;
     %let sortvar = ANC2012;
     %let TypeOfDat = ANC12;
     %let geosuf = _anc12;
     %let ncdb00in = ncdb.Ncdb_sum_anc12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_anc12;
  %end;
 %else %if %upcase( &source_geo ) = CLTR00 %then %do;
     %let sortvar = CLUSTER_TR2000;
     %let TypeOfDat = CLTR00;
     %let geosuf = _cltr00 ;
     %let ncdb00in = ncdb.Ncdb_sum_cltr00;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cltr00;
  %end;
 %else %if %upcase( &source_geo ) = PSA12 %then %do;
     %let sortvar = PSA2012;
     %let TypeOfDat = PSA12;
     %let ncdb00in = ncdb.Ncdb_sum_psa12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_psa12;
  %end;
 %else %if %upcase( &source_geo ) = ZIP %then %do;
     %let sortvar = ZIP;
     %let TypeOfDat = ZIP;
     %let geosuf = _zip;
     %let ncdb00in = ncdb.Ncdb_sum_zip;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_zip;
  %end;
 %else %if %upcase( &source_geo ) = CL17 %then %do;
     %let sortvar = CLUSTER2017;
     %let TypeOfDat = CL17;
     %let geosuf = _cl17;
     %let ncdb00in = ncdb.Ncdb_sum_cl17;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cl17;
  %end;

 
proc sort data = &ncdb00in. out = ncdb00&geosuf.; by &sortvar.; run;
proc sort data = &ncdb10in. out = ncdb10&geosuf.; by &sortvar.; run;


data ncdb_hu_count&geosuf.;
	merge ncdb00&geosuf. ncdb10&geosuf.;
	by &sortvar.;
	HUnits_2000 = NumHsgUnits_2000;
	HUnits_2010 = NumHsgUnits_2010;

	/* Calculate interval var from 2000 and 2010 counts */
	intval = (HUnits_2010-HUnits_2000)/10;

	/* Interpolate data from 2001 - 2009 */
	HUnits_2001 = HUnits_2000 + intval;
	HUnits_2002 = HUnits_2001 + intval;
	HUnits_2003 = HUnits_2002 + intval;
	HUnits_2004 = HUnits_2003 + intval;
	HUnits_2005 = HUnits_2004 + intval;
	HUnits_2006 = HUnits_2005 + intval;
	HUnits_2007 = HUnits_2006 + intval;
	HUnits_2008 = HUnits_2007 + intval;
	HUnits_2009 = HUnits_2008 + intval;

	/* Use 2000 data for older years */
	HUnits_1997 = HUnits_2000;
	HUnits_1998 = HUnits_2000;
	HUnits_1999 = HUnits_2000;

	/* Use 2000 data for newer years */
	HUnits_2011 = HUnits_2010;
	HUnits_2012 = HUnits_2010;
	HUnits_2013 = HUnits_2010;
	HUnits_2014 = HUnits_2010;
	HUnits_2015 = HUnits_2010;
	HUnits_2016 = HUnits_2010;
	HUnits_2017 = HUnits_2010;
	HUnits_2018 = HUnits_2010;
	HUnits_2019 = HUnits_2010;

	/* Keep housing unit counts and goe var */
	keep &sortvar. HUnits_:;
run;

proc sort data = ncdb_hu_count&geosuf.; by &sortvar.; run;


%mend housing_unit_count;




/* End Macro */
