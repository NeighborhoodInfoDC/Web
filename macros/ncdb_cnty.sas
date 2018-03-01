/**************************************************************************
 Program:  ncdb_cnty
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/01/2018
 Version:  SAS 9.4
 Environment:  Windows
 Description: Macro to summarize NCDB data to county-level.
 Modifications: 

**************************************************************************/

%macro ncdb_cnty;

/* 1990 and 2000 NCDB file */
data Ncdb_sum_was15_tr10;
	set ncdb.Ncdb_sum_was15_tr10;
	county  = substr(geo2010,1,5);
	if county in ("24003","24043","51069","51113","51171") then delete;
	format county $CNTY15F.;
run;

proc summary data = Ncdb_sum_was15_tr10;
	class county;
	var _numeric_;
	output out = Ncdb_sum_was15_sum sum=;
run;

data Ncdb_sum_was15_cnty;
	set Ncdb_sum_was15_sum;
	if county ^= " ";
	drop _type_ _freq_;
run;


/* 2010 NCDB file */
data Ncdb_2010_was15;
	set ncdb.Ncdb_2010_was15;
	county  = substr(geo2010,1,5);
	if county in ("24003","24043","51069","51113","51171") then delete;
	format county $CNTY15F.;
run;

proc summary data = Ncdb_2010_was15;
	class county;
	var _numeric_;
	output out = Ncdb_2010_was15_sum sum=;
run;

data Ncdb_2010_sum_was15_cnty;
	set Ncdb_2010_was15_sum;
	if county ^= " ";
	drop _type_ _freq_;
run;

%mend ncdb_cnty;
