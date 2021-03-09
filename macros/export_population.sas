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

%macro export_population (source_geo);

%let topic = population ;

/* Labels for ACS years */
%let y_lbl = %sysfunc( translate( &acsyr., '-', '_' ) );
%let py_lbl = %sysfunc( translate( &prevacsyr., '-', '_' ) );

** Last year of ACS data for inflation adjustment **;
%let last_acs = %substr(&acsyr.,6,2);
%let acs_infl_yr = 20&last_acs. ;

%if %upcase( &source_geo ) = GEO2010 %then %do;
     %let geo = Geo2010;
     %let geosuf = _tr10;
     %let ncdb00in = ncdb.Ncdb_sum_was15_tr10;
	 %let ncdb10in = ncdb.Ncdb_2010_was15;
	 %let acsin = acs.acs_&acsyr._dc_sum_tr_tr10 acs.acs_&acsyr._md_sum_tr_tr10 acs.acs_&acsyr._va_sum_tr_tr10 acs.acs_&acsyr._wv_sum_tr_tr10;
	 %let prevacsin = acs.acs_&prevacsyr._dc_sum_tr_tr10 acs.acs_&prevacsyr._md_sum_tr_tr10 acs.acs_&prevacsyr._va_sum_tr_tr10 acs.acs_&prevacsyr._wv_sum_tr_tr10;
  %end;
%else %if %upcase( &source_geo ) = COUNTY %then %do;
  	 %ncdb_cnty;
     %let geo = County;
     %let geosuf = _cnty;
     %let ncdb00in = work.Ncdb_sum_was15_cnty;
	 %let ncdb10in = work.Ncdb_2010_sum_was15_cnty;
	 %let acsin = acs.acs_&acsyr._dc_sum_regcnt_regcnt acs.acs_&acsyr._md_sum_regcnt_regcnt acs.acs_&acsyr._va_sum_regcnt_regcnt acs.acs_&acsyr._wv_sum_regcnt_regcnt;
	 %let prevacsin = acs.acs_&prevacsyr._dc_sum_regcnt_regcnt acs.acs_&prevacsyr._md_sum_regcnt_regcnt acs.acs_&prevacsyr._va_sum_regcnt_regcnt acs.acs_&prevacsyr._wv_sum_regcnt_regcnt;
  %end;
%else %if %upcase( &source_geo ) = CITY %then %do;
     %let geo = City;
     %let geosuf = _city;
     %let ncdb00in = ncdb.Ncdb_sum_city;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_city;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_city;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_city;
  %end;
%else %if %upcase( &source_geo ) = WD12 %then %do;
     %let geo = Ward2012;
     %let geosuf = _wd12;
     %let ncdb00in = ncdb.Ncdb_sum_wd12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_wd12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_wd12 ;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_wd12;
  %end;
%else %if %upcase( &source_geo ) = ANC12 %then %do;
     %let geo = Anc2012;
     %let geosuf = _anc12;
     %let ncdb00in = ncdb.Ncdb_sum_anc12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_anc12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_anc12;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_anc12;
  %end;
 %else %if %upcase( &source_geo ) = CLTR00 %then %do;
     %let geo = Cluster_tr2000;
     %let geosuf = _cltr00 ;
     %let ncdb00in = ncdb.Ncdb_sum_cltr00;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cltr00;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_cltr00;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_cltr00;
  %end;
 %else %if %upcase( &source_geo ) = PSA12 %then %do;
     %let geo = Psa2012;
     %let geosuf = _psa12;
     %let ncdb00in = ncdb.Ncdb_sum_psa12;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_psa12;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_psa12;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_psa12;
  %end;
 %else %if %upcase( &source_geo ) = ZIP %then %do;
     %let geo = Zip;
     %let geosuf = _zip;
     %let ncdb00in = ncdb.Ncdb_sum_zip;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_zip;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_zip;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_zip;
  %end;
 %else %if %upcase( &source_geo ) = CL17 %then %do;
     %let geo = Cluster2017;
     %let geosuf = _cl17;
     %let ncdb00in = ncdb.Ncdb_sum_cl17;
	 %let ncdb10in = ncdb.Ncdb_sum_2010_cl17;
	 %let acsin = Acs.Acs_&acsyr._dc_sum_tr_cl17;
	 %let prevacsin = Acs.Acs_&prevacsyr._dc_sum_tr_cl17;
  %end;


%macro ncdbloop (ds,ncdbyr);


/* Need to rename variables in NDCB 2010 */
data rename_ncdb10;
	set &ncdb10in.;

	%if %upcase( &source_geo ) = COUNTY or
	    %upcase( &source_geo ) = GEO2010 %then %do;
	TotPop_2010 = TRCTPOP1;
	PopUnder18Years_2010 = CHILD1N;
	Pop65andOverYears_2010 = OLD1N;
	PopWhiteNonHispBridge_2010 = SHRNHW1N;
	PopBlackNonHispBridge_2010 = SHRNHB1N;
	PopAsianPINonHispBridge_2010 = SHRNHA1N;
	PopWithRace_2010 = SHR1D;
	PopHisp_2010 = SHRHSP1N;
	%end;

run;


data Ncdb_&ncdbyr._&topic.&geosuf.;

%if &ds. = ncdb %then %do;

	%if &ncdbyr. = 1990 %then %do;
	length timeframe $ 15;
	set &ncdb00in.;

	start_date = '01jan90'd;
	end_date = '31dec90'd;
	%end;

	%else %if &ncdbyr. = 2000 %then %do;
	length timeframe $ 15;
	set &ncdb00in.;

	start_date = '01jan00'd;
	end_date = '31dec00'd;
	%end;

	%else %if &ncdbyr. = 2010 %then %do;
	length timeframe $ 15;
	set rename_ncdb10;

	start_date = '01jan10'd;
	end_date = '31dec10'd;

	%end;

	format start_date end_date date9. ;

	/* Unformatted tract ID */
	%geo_nf;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	/* County ID */
	ucounty=substr(geo2010,1,5);
	%end;

	/* timeframe */
	timeframe = "&ncdbyr" ;
%end;

%else %if &ds. = prevacs %then %do;
	%let ncdbyr = &prevacsyr.;

	length timeframe $ 15;
	set &prevacsin.;

	%geo_nf;

	timeframe = "&py_lbl." ;

	%let sy = %substr(&prevacsyr.,3,2);
	%let ey = %substr(&prevacsyr.,6,2);

	start_date = "01jan&sy."d;
	end_date = "31dec&ey."d;

	format start_date end_date date9. ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	%else %if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;
%end;

%else %do;
	%let ncdbyr = &acsyr.;

	length timeframe $ 15;
	set &acsin.;

	%geo_nf;

	timeframe = "&y_lbl." ;

	%let sy = %substr(&acsyr.,3,2);
	%let ey = %substr(&acsyr.,6,2);

	start_date = "01jan&sy."d;
	end_date = "31dec&ey."d;
	format start_date end_date date9. ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

%end;

%if %upcase( &source_geo ) = GEO2010 %then %do;
/* Keep tracts in the MSA */
%define_dcmetro (countyvar = ucounty);
%end;

%else %if %upcase( &source_geo ) = COUNTY %then %do;
if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
			  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
			  "51685","54037");
%end;

%Pct_calc( var=PctPopUnder18Years, label=% children, num=PopUnder18Years, den=TotPop, years=&ncdbyr. );
%Pct_calc( var=PctPop65andOverYears, label=% seniors, num=Pop65andOverYears, den=TotPop, years= &ncdbyr. );
%Pct_calc( var=PctForeignBorn, label=% foreign born, num=PopForeignBorn, den=TotPop, years= &ncdbyr.);
%Pct_calc( var=PctBlackNonHispBridge, label=% black non-Hispanic, num=PopBlackNonHispBridge, den=PopWithRace, years=&ncdbyr. );
%Pct_calc( var=PctWhiteNonHispBridge, label=% white non-Hispanic, num=PopWhiteNonHispBridge, den=PopWithRace, years=&ncdbyr. );
%Pct_calc( var=PctHisp, label=% Hispanic, num=PopHisp, den=PopWithRace, years=&ncdbyr. );
%Pct_calc( var=PctAsianPINonHispBridge, label=% Asian/P.I. non-Hispanic, num=PopAsianPINonHispBridge, den=PopWithRace, years=&ncdbyr. );


%if &ncdbyr. = 1990 or &ncdbyr. = 2000 or &ncdbyr. = 2010 %then %do;
keep &geo._nf &geo. start_date end_date timeframe
	 TotPop_&ncdbyr. PctPopUnder18Years_&ncdbyr. PctPop65andOverYears_&ncdbyr. 
	 PctBlackNonHispBridge_&ncdbyr. PctWhiteNonHispBridge_&ncdbyr. PctHisp_&ncdbyr. PctAsianPINonHispBridge_&ncdbyr.;
%end;

%else %do;
keep &geo._nf &geo. start_date end_date timeframe
	 TotPop_&ncdbyr. PctPopUnder18Years_&ncdbyr. PctPop65andOverYears_&ncdbyr. PctForeignBorn_&ncdbyr. 
	 PctBlackNonHispBridge_&ncdbyr. PctWhiteNonHispBridge_&ncdbyr. PctHisp_&ncdbyr. PctAsianPINonHispBridge_&ncdbyr.
	 PctFamiliesOwnChildrenFH_&ncdbyr. ;
%end;

rename 	TotPop_&ncdbyr. = TotPop;
rename	PctPopUnder18Years_&ncdbyr.  = PctPopUnder18Years;
rename	PctPop65andOverYears_&ncdbyr. = PctPop65andOverYears;
rename	PctBlackNonHispBridge_&ncdbyr. = PctBlackNonHispBridge;
rename	PctWhiteNonHispBridge_&ncdbyr. = PctWhiteNonHispBridge;
rename	PctHisp_&ncdbyr. = PctHisp;
rename	PctAsianPINonHispBridge_&ncdbyr. = PctAsianPINonHispBridge;


%if &ds. = acs or &ds. = prevacs %then %do;

	
	%Pct_calc( var=PctFamiliesOwnChildrenFH, label=% female-headed families with children, num=NumFamiliesOwnChildrenFH, den=NumFamiliesOwnChildren, years=&ncdbyr. );

	%Moe_prop_a( var=PctPopUnder18Years_m_&ncdbyr., mult=100, num=PopUnder18Years_&ncdbyr., den=TotPop_&ncdbyr., 
	                       num_moe=mPopUnder18Years_&ncdbyr., den_moe=mTotPop_&ncdbyr. );

	%Moe_prop_a( var=PctPop65andOverYears_m_&ncdbyr., mult=100, num=Pop65andOverYears_&ncdbyr., den=TotPop_&ncdbyr., 
	                       num_moe=mPop65andOverYears_&ncdbyr., den_moe=mTotPop_&ncdbyr. );

	%Moe_prop_a( var=PctForeignBorn_m_&ncdbyr., mult=100, num=PopForeignBorn_&ncdbyr., den=TotPop_&ncdbyr., 
                       num_moe=mPopForeignBorn_&ncdbyr., den_moe=mTotPop_&ncdbyr. );

	%Moe_prop_a( var=PctBlackNonHispBridge_m_&ncdbyr., mult=100, num=PopBlackNonHispBridge_&ncdbyr., den=PopWithRace_&ncdbyr., 
	                       num_moe=mPopBlackNonHispBridge_&ncdbyr., den_moe=mPopWithRace_&ncdbyr. );

	%Moe_prop_a( var=PctWhiteNonHispBridge_m_&ncdbyr., mult=100, num=PopWhiteNonHispBridge_&ncdbyr., den=PopWithRace_&ncdbyr., 
	                       num_moe=mPopWhiteNonHispBridge_&ncdbyr., den_moe=mPopWithRace_&ncdbyr. );

	%Moe_prop_a( var=PctHisp_m_&ncdbyr., mult=100, num=PopHisp_&ncdbyr., den=PopWithRace_&ncdbyr., 
	                       num_moe=mPopHisp_&ncdbyr., den_moe=mPopWithRace_&ncdbyr. );

	%Moe_prop_a( var=PctAPINonHispBridge_m_&ncdbyr., mult=100, num=PopAsianPINonHispBridge_&ncdbyr., den=PopWithRace_&ncdbyr., 
	                       num_moe=mPopAsianPINonHispBridge_&ncdbyr., den_moe=mPopWithRace_&ncdbyr. );

	 %Moe_prop_a( var=PctFamiliesOwnChildFH_m_&ncdbyr., mult=100, num=NumFamiliesOwnChildrenFH_&ncdbyr., den=NumFamiliesOwnChildren_&ncdbyr., 
	                       num_moe=mNumFamiliesOwnChildFH_&ncdbyr., den_moe=mNumFamiliesOwnChildren_&ncdbyr. );


	keep PctPopUnder18Years_m_&ncdbyr. PctPop65andOverYears_m_&ncdbyr. PctForeignBorn_m_&ncdbyr. PctBlackNonHispBridge_m_&ncdbyr.
		 PctWhiteNonHispBridge_m_&ncdbyr. PctHisp_m_&ncdbyr. PctAPINonHispBridge_m_&ncdbyr. PctFamiliesOwnChildFH_m_&ncdbyr.
		 mTotPop_&ncdbyr.;

	rename  PctForeignBorn_&ncdbyr. = PctForeignBorn
			PctFamiliesOwnChildrenFH_&ncdbyr. =  PctFamiliesOwnChildrenFH

			mTotPop_&ncdbyr. = TotPop_m
			PctPopUnder18Years_m_&ncdbyr. = PctPopUnder18Years_m
			PctPop65andOverYears_m_&ncdbyr. = PctPop65andOverYears_m
			PctForeignBorn_m_&ncdbyr. = PctForeignBorn_m
			PctBlackNonHispBridge_m_&ncdbyr. = PctBlackNonHispBridge_m
			PctWhiteNonHispBridge_m_&ncdbyr. = PctWhiteNonHispBridge_m
			PctHisp_m_&ncdbyr. = PctHisp_m
			PctAPINonHispBridge_m_&ncdbyr. = PctAPINonHispBridge_m
			PctFamiliesOwnChildFH_m_&ncdbyr. = PctFamiliesOwnChildFH_m;

%end;


run;

%mend ncdbloop;


%ncdbloop (ncdb,1990);
%ncdbloop (ncdb,2000);
%ncdbloop (ncdb,2010);
%ncdbloop (acs,acs);
%ncdbloop (prevacs,prevacs);


data acs_all&geosuf.;
	set &acsin.; 
	%if %upcase( &source_geo ) = COUNTY %then %do;
	if county in ("11001","24009","24017","24021","24031","24033","51013","51043","51047","51059","51061",
				  "51107","51153","51157","51177","51179","51187","51510","51600","51610","51630","51683",
				  "51685","54037");
	%end;
run;

data ch_&topic.&geosuf.;
	merge acs_all&geosuf. &ncdb00in. rename_ncdb10;
	by &geo.;

	if TotPop_1990 > 0 then PctChgTotPop_1990_2000 = %pctchg( TotPop_1990, TotPop_2000 );
	if TotPop_2000 > 0 then PctChgTotPop_2000_2010 = %pctchg( TotPop_2000, TotPop_2010 );
    if TotPop_2000 > 0 then PctChgTotPop_2000_&acsyr. = %pctchg( TotPop_2000, TotPop_&acsyr. );

	if PopUnder18Years_1990 > 0 then PctChgPopUnder18Years_1990_2000 = %pctchg( PopUnder18Years_1990, PopUnder18Years_2000 );
	if PopUnder18Years_2000 > 0 then PctChgPopUnder18Yea_2000_2010 = %pctchg( PopUnder18Years_2000, PopUnder18Years_2010 );
    if PopUnder18Years_2000 > 0 then PctChgPopUnder18Yea_2000_&acsyr. = %pctchg( PopUnder18Years_2000, PopUnder18Years_&acsyr. );

	if Pop65andOverYears_1990 > 0 then PctChgPop65andOverYear_1990_2000 = %pctchg( Pop65andOverYears_1990, Pop65andOverYears_2000 );
	if Pop65andOverYears_2000 > 0 then PctChgPop65andOverY_2000_2010 = %pctchg( Pop65andOverYears_2000, Pop65andOverYears_2010 );
    if Pop65andOverYears_2000 > 0 then PctChgPop65andOverY_2000_&acsyr. = %pctchg( Pop65andOverYears_2000, Pop65andOverYears_&acsyr. );

run;

data ch_&topic.&geosuf._1990_2000;
	length timeframe $ 15;
	set ch_&topic.&geosuf.;

	/* Unformatted tract ID */
	%geo_nf;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	/* ACS timeframe */
	timeframe = "2000" ;

	/* Populate start and end dates */
	start_date = '01jan90'd;
	end_date = '31dec00'd;
	format start_date end_date date9. ;

	PctChgTotPop = PctChgTotPop_1990_2000;
	PctChgPopUnder18Years = PctChgPopUnder18Years_1990_2000;
	PctChgPop65andOverYear = PctChgPop65andOverYear_1990_2000;

	keep &geo._nf &geo. start_date end_date timeframe PctChgTotPop PctChgPopUnder18Years PctChgPop65andOverYear;
run;


data ch_&topic.&geosuf._2000_2010;
	length timeframe $ 15;
	set ch_&topic.&geosuf.;

	/* Unformatted tract ID */
	%geo_nf;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	%define_dcmetro (countyvar = ucounty);
	%end;

	/* ACS timeframe */
	
	timeframe = "2010" ;

	/* Populate start and end dates */
	start_date = '01jan00'd;
	end_date = '31dec10'd;
	format start_date end_date date9. ;


	PctChgTotPop = PctChgTotPop_2000_2010;
	PctChgPopUnder18Years = PctChgPopUnder18Yea_2000_2010;
	PctChgPop65andOverYear = PctChgPop65andOverY_2000_2010;

	keep &geo._nf &geo. start_date end_date timeframe PctChgTotPop PctChgPopUnder18Years PctChgPop65andOverYear;

run;

data alldata_&topic.&geosuf.;
	set Ncdb_acs_&topic.&geosuf. (in=a) 
	Ncdb_prevacs_&topic.&geosuf. (in=b)
	Ncdb_2010_&topic.&geosuf. (in=c) 
	Ncdb_2000_&topic.&geosuf. (in=d) 
	Ncdb_1990_&topic.&geosuf. (in=e) 
	ch_&topic.&geosuf._2000_2010 (in=f) 
	ch_&topic.&geosuf._1990_2000 (in=g);

	if a or b or c or d or e then do;
	PctChgTotPop = .x;
	PctChgPopUnder18Years = .x;
	PctChgPop65andOverYear = .x;
	end; 

	else if f or g then do;
	Totpop = .x;
	PctPopUnder18Years = .x;
	PctPop65andOverYears = .x;
	PctForeignBorn = .x;
	PctBlackNonHispBridge = .x;
	PctWhiteNonHispBridge = .x;
	PctHisp = .x;
	PctAsianPINonHispBridge = .x;
	PctFamiliesOwnChildrenFH = .x;
	PctPopUnder18Years_m = .x;
	PctPop65andOverYears_m = .x;
	PctForeignBorn_m = .x;
	PctBlackNonHispBridge_m = .x;
	PctWhiteNonHispBridge_m = .x;
	PctHisp_m = .x;
	PctAPINonHispBridge_m = .x;
	PctFamiliesOwnChildFH_m = .x;
	end;

run;

%suppress_lowpop (in_check = alldata_&topic.&geosuf.,
				  out_check = checked_&topic.&geosuf.);



data &topic.&geosuf.;
	set checked_&topic.&geosuf. 

		/* Lowercase the geo variable names */
		(rename=(&geo=%sysfunc(lowcase(&geo.))
		 &geo._nf=%sysfunc(lowcase(&geo._nf)))) ;

	%if %upcase( &source_geo ) = GEO2010 %then %do;
	ucounty=substr(geo2010,1,5);
	format ucounty $profile_cnty.;
	%indc_flag (countyvar = ucounty);
	%end;
	%else %if %upcase( &source_geo ) ^= COUNTY %then %do;
	indc = 1;
	%end;

	label Totpop = "Total Population"
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
		  Totpop_m = "Total Population MOE"
		  PctPopUnder18Years_m = "% children MOE"
		  PctPop65andOverYears_m = "% senior MOE"
		  PctForeignBorn_m = "% foreign born MOE"
		  PctBlackNonHispBridge_m = "% black non-Hispanic MOE"
		  PctWhiteNonHispBridge_m = "% white non-Hispanic MOE"
		  PctHisp_m = "% Hispanic MOE"
		  PctAPINonHispBridge_m = "% Asian/P.I. non-Hispanic MOE"
		  PctFamiliesOwnChildFH_m = "% female-headed families with children MOE"
		  ;

	format TotPop PctPopUnder18Years PctPop65andOverYears PctForeignBorn PctBlackNonHispBridge PctWhiteNonHispBridge PctHisp
		   PctAsianPINonHispBridge PctFamiliesOwnChildrenFH PctChgTotPop PctChgPopUnder18Years PctChgPop65andOverYear Totpop_m
		   PctPopUnder18Years_m PctPop65andOverYears_m PctForeignBorn_m PctBlackNonHispBridge_m PctWhiteNonHispBridge_m PctHisp_m
		   PctAPINonHispBridge_m PctFamiliesOwnChildFH_m profnum.;
run;


/* Create metadata for the dataset */
proc contents data = &topic.&geosuf. out = &topic.&geosuf._metadata_order noprint;
run;

data &topic.&geosuf._metadata;
	set &topic.&geosuf._metadata_order;

	if name = "TotPop" then weborder = 1;
	else if name = "PctChgTotPop" then weborder = 2;
	else if name = "PctPopUnder18Years" then weborder = 3;
	else if name = "PctPopUnder18Years_m" then weborder = 4;
	else if name = "PctChgPopUnder18Years" then weborder = 5;
	else if name = "PctPop65andOverYears" then weborder = 6;
	else if name = "PctPop65andOverYears_m" then weborder = 7;
	else if name = "PctChgPop65andOverYear" then weborder = 8;
	else if name = "PctBlackNonHispBridge" then weborder = 9;
	else if name = "PctBlackNonHispBridge_m" then weborder = 10;
	else if name = "PctWhiteNonHispBridge" then weborder = 11;
	else if name = "TotPop_m" then weborder = 12;
	else if name = "PctWhiteNonHispBridge_m" then weborder = 13;
	else if name = "PctHisp" then weborder = 14;
	else if name = "PctHisp_m" then weborder = 15;
	else if name = "PctAsianPINonHispBridge" then weborder = 16;
	else if name = "PctAPINonHispBridge_m" then weborder = 17;
	else if name = "PctForeignBorn" then weborder = 18;
	else if name = "PctForeignBorn_m" then weborder = 19;
	else if name = "PctFamiliesOwnChildrenFH" then weborder = 20;
	else if name = "PctFamiliesOwnChildFH_m" then weborder = 21;

run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&topic.\&topic.&geosuf._metadata.csv";
	proc print data =&topic.&geosuf._metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&topic.\&topic.&geosuf..csv";
	proc print data =&topic.&geosuf. noobs;
	run;
ods csv close;


%mend export_population;



/* End Macro */
