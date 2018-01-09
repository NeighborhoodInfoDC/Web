/**************************************************************************
 Program:  export_population
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_population (
datafile=,
metadatafile=
);

%let topic = population ;

%macro ncdbloop (ds,ncdbyr);

data Ncdb_&ncdbyr._&topic.;

%if &ds. = ncdb %then %do;

	%if &ncdbyr. = 1990 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	start_date = '01jan90'd;
	end_date = '31dec90'd;
	%end;

	%else %if &ncdbyr. = 2000 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	start_date = '01jan00'd;
	end_date = '31dec00'd;
	%end;

	%else %if &ncdbyr. = 2010 %then %do;
	length timeframe $ 15;
	set ncdb.Ncdb_2010_was15;

	start_date = '01jan10'd;
	end_date = '31dec10'd;
	%end;

	format start_date end_date date9. ;

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* County ID */
	ucounty=substr(geo2010,1,5);

	/* timeframe */
	timeframe = "&ncdbyr" ;
%end;

%else %do;

	set acs_all;
	%let ncdbyr = &acsyr.;

%end;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);

	%Pct_calc( var=PctPopUnder18Years, label=% children, num=PopUnder18Years, den=TotPop, years=&ncdbyr. );
	%Pct_calc( var=PctPop65andOverYears, label=% seniors, num=Pop65andOverYears, den=TotPop, years= &ncdbyr. );
	%Pct_calc( var=PctForeignBorn, label=% foreign born, num=PopForeignBorn, den=TotPop, years= &ncdbyr.);
	%Pct_calc( var=PctBlackNonHispBridge, label=% black non-Hispanic, num=PopBlackNonHispBridge, den=PopWithRace, years=&ncdbyr. );
    %Pct_calc( var=PctWhiteNonHispBridge, label=% white non-Hispanic, num=PopWhiteNonHispBridge, den=PopWithRace, years=&ncdbyr. );
    %Pct_calc( var=PctHisp, label=% Hispanic, num=PopHisp, den=PopWithRace, years=&ncdbyr. );
    %Pct_calc( var=PctAsianPINonHispBridge, label=% Asian/P.I. non-Hispanic, num=PopAsianPINonHispBridge, den=PopWithRace, years=&ncdbyr. );
	%Pct_calc( var=PctFamiliesOwnChildrenFH, label=% female-headed families with children, num=NumFamiliesOwnChildrenFH, den=NumFamiliesOwnChildren, years=&ncdbyr. );


	keep geo2010_nf geo2010 start_date end_date timeframe
		 TotPop_&ncdbyr. PctPopUnder18Years_&ncdbyr. PctPop65andOverYears_&ncdbyr. PctForeignBorn_&ncdbyr. 
		 PctBlackNonHispBridge_&ncdbyr. PctWhiteNonHispBridge_&ncdbyr. PctHisp_&ncdbyr. PctAsianPINonHispBridge_&ncdbyr.
		 PctFamiliesOwnChildrenFH_&ncdbyr.;

	rename 	TotPop_&ncdbyr. = 	TotPop
		   	PctPopUnder18Years_&ncdbyr.  = PctPopUnder18Years
			PctPop65andOverYears_&ncdbyr. = PctPop65andOverYears
			PctForeignBorn_&ncdbyr. = PctForeignBorn
		 	PctBlackNonHispBridge_&ncdbyr. = PctBlackNonHispBridge
			PctWhiteNonHispBridge_&ncdbyr. = PctWhiteNonHispBridge
			PctHisp_&ncdbyr. = PctHisp
			PctAsianPINonHispBridge_&ncdbyr. = PctAsianPINonHispBridge
			PctFamiliesOwnChildrenFH_&ncdbyr. =  PctFamiliesOwnChildrenFH
;


%if &ds. = acs %then %do;

	%Moe_prop_a( var=PctPopUnder18Years_m_&acsyr., mult=100, num=PopUnder18Years_&acsyr., den=TotPop_&acsyr., 
	                       num_moe=mPopUnder18Years_&acsyr., den_moe=mTotPop_&acsyr. );

	%Moe_prop_a( var=PctPop65andOverYears_m_&acsyr., mult=100, num=Pop65andOverYears_&acsyr., den=TotPop_&acsyr., 
	                       num_moe=mPop65andOverYears_&acsyr., den_moe=mTotPop_&acsyr. );

	%Moe_prop_a( var=PctForeignBorn_m_&acsyr., mult=100, num=PopForeignBorn_&acsyr., den=TotPop_&acsyr., 
                       num_moe=mPopForeignBorn_&acsyr., den_moe=mTotPop_&acsyr. );

	%Moe_prop_a( var=PctBlackNonHispBridge_m_&acsyr., mult=100, num=PopBlackNonHispBridge_&acsyr., den=PopWithRace_&acsyr., 
	                       num_moe=mPopBlackNonHispBridge_&acsyr., den_moe=mPopWithRace_&acsyr. );

	%Moe_prop_a( var=PctWhiteNonHispBridge_m_&acsyr., mult=100, num=PopWhiteNonHispBridge_&acsyr., den=PopWithRace_&acsyr., 
	                       num_moe=mPopWhiteNonHispBridge_&acsyr., den_moe=mPopWithRace_&acsyr. );

	%Moe_prop_a( var=PctHisp_m_&acsyr., mult=100, num=PopHisp_&acsyr., den=PopWithRace_&acsyr., 
	                       num_moe=mPopHisp_&acsyr., den_moe=mPopWithRace_&acsyr. );

	%Moe_prop_a( var=PctAPINonHispBridge_m_&acsyr., mult=100, num=PopAsianPINonHispBridge_&acsyr., den=PopWithRace_&acsyr., 
	                       num_moe=mPopAsianPINonHispBridge_&acsyr., den_moe=mPopWithRace_&acsyr. );

	 %Moe_prop_a( var=PctFamiliesOwnChildFH_m_&acsyr., mult=100, num=NumFamiliesOwnChildrenFH_&acsyr., den=NumFamiliesOwnChildren_&acsyr., 
	                       num_moe=mNumFamiliesOwnChildFH_&acsyr., den_moe=mNumFamiliesOwnChildren_&acsyr. );


	keep PctPopUnder18Years_m_&acsyr. PctPop65andOverYears_m_&acsyr. PctForeignBorn_m_&acsyr. PctBlackNonHispBridge_m_&acsyr.
		 PctWhiteNonHispBridge_m_&acsyr. PctHisp_m_&acsyr. PctAPINonHispBridge_m_&acsyr. PctFamiliesOwnChildFH_m_&acsyr.;

	rename 	PctPopUnder18Years_m_&acsyr. = PctPopUnder18Years_m
			PctPop65andOverYears_m_&acsyr. = PctPop65andOverYears_m
			PctForeignBorn_m_&acsyr. = PctForeignBorn_m
			PctBlackNonHispBridge_m_&acsyr. = PctBlackNonHispBridge_m
			PctWhiteNonHispBridge_m_&acsyr. = PctWhiteNonHispBridge_m
			PctHisp_m_&acsyr. = PctHisp_m
			PctAPINonHispBridge_m_&acsyr. = PctAPINonHispBridge_m
			PctFamiliesOwnChildFH_m_&acsyr. = PctFamiliesOwnChildFH_m;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (acs,acs);



data change_&topic.;
	merge acs_all ncdb.Ncdb_sum_was15_tr10;
	by geo2010;

	if TotPop_1990 > 0 then PctChgTotPop_1990_2000 = %pctchg( TotPop_1990, TotPop_2000 );
    if TotPop_2000 > 0 then PctChgTotPop_2000_&acsyr. = %pctchg( TotPop_2000, TotPop_&acsyr. );

	if PopUnder18Years_1990 > 0 then PctChgPopUnder18Years_1990_2000 = %pctchg( PopUnder18Years_1990, PopUnder18Years_2000 );
    if PopUnder18Years_2000 > 0 then PctChgPopUnder18Yea_2000_&acsyr. = %pctchg( PopUnder18Years_2000, PopUnder18Years_&acsyr. );

	if Pop65andOverYears_1990 > 0 then PctChgPop65andOverYear_1990_2000 = %pctchg( Pop65andOverYears_1990, Pop65andOverYears_2000 );
    if Pop65andOverYears_2000 > 0 then PctChgPop65andOverY_2000_&acsyr. = %pctchg( Pop65andOverYears_2000, Pop65andOverYears_&acsyr. );
run;


data change_&topic._1990_2000;
	length timeframe $ 15;
	set change_&topic.;

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* County ID */
	ucounty=substr(geo2010,1,5);

	/* ACS timeframe */
	timeframe = "1990 to 2000" ;

	/* Populate start and end dates */
	start_date = '01jan90'd;
	end_date = '31dec00'd;
	format start_date end_date date9. ;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);

	PctChgTotPop = PctChgTotPop_1990_2000;
	PctChgPopUnder18Years = PctChgPopUnder18Years_1990_2000;
	PctChgPop65andOverYear = PctChgPop65andOverYear_1990_2000;

	keep geo2010_nf geo2010 start_date end_date timeframe PctChgTotPop PctChgPopUnder18Years PctChgPop65andOverYear;
run;


data change_&topic._2000_ACS;
	length timeframe $ 15;
	set change_&topic.;

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* County ID */
	ucounty=substr(geo2010,1,5);

	/* ACS timeframe */
	
	timeframe = "2000 to 2012-16" ;

	/* Populate start and end dates */
	start_date = '01jan00'd;
	end_date = '31dec16'd;
	format start_date end_date date9. ;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);

	PctChgTotPop = PctChgTotPop_2000_&acsyr.;
	PctChgPopUnder18Years = PctChgPopUnder18Yea_2000_&acsyr.;
	PctChgPop65andOverYear = PctChgPop65andOverY_2000_&acsyr.;

	keep geo2010_nf geo2010 start_date end_date timeframe PctChgTotPop PctChgPopUnder18Years PctChgPop65andOverYear;

run;



data &topic._tr10;
	set Ncdb_acs_&topic. ncdb_2000_&topic. ncdb_1990_&topic. change_&topic._2000_ACS change_&topic._1990_2000;

	/* County ID */
	ucounty=substr(geo2010,1,5);
	drop ucounty;

	%indc_flag (countyvar = ucounty);

	label Totpop = "Population"
		  PctPopUnder18Years = "% children"
		  PctPop65andOverYears = "% senior"
		  PctForeignBorn = "% foreign born"
		  PctBlackNonHispBridge = "% black non-Hispanic"
		  PctWhiteNonHispBridge = "% white non-Hispanic"
		  PctHisp = "% Hispanic"
		  PctAsianPINonHispBridge = "% Asian/P.I. non-Hispanic"
		  PctFamiliesOwnChildrenFH = "% female-headed families with children"
		  PctChgTotPop = "% change population"
		  PctChgPopUnder18Years = "% change child population"
		  PctChgPop65andOverYear = "% change senior population"
		  PctPopUnder18Years_m = "% children MOE"
		  PctPop65andOverYears_m = "% senior MOE"
		  PctForeignBorn_m = "% foreign born MOE"
		  PctBlackNonHispBridge_m = "% black non-Hispanic MOE"
		  PctWhiteNonHispBridge_m = "% white non-Hispanic MOE"
		  PctHisp_m = "% Hispanic MOE"
		  PctAPINonHispBridge_m = "% Asian/P.I. non-Hispanic MOE"
		  PctFamiliesOwnChildFH_m = "% female-headed families with children MOE"
		  ;
run;


/* Create metadata for the dataset */
proc contents data = &topic._tr10 out = &topic._tr10_metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&metadatafile.";
	proc print data =&topic._tr10_metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&datafile.";
	proc print data =&topic._tr10 noobs;
	run;
ods csv close;


%mend export_population;



/* End Macro */
