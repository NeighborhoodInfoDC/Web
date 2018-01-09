/**************************************************************************
 Program:  export_income
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%macro export_income (
datafile=,
metadatafile=
);

%include "&_dcdata_default_path.\tanf\prog\TANF_forweb.sas";
%include "&_dcdata_default_path.\tanf\prog\FS_forweb.sas";

data acs_income;
	set acs_all;

	%Pct_calc( var=PctPoorPersons, label=Poverty rate (%), num=PopPoorPersons, den=PersonsPovertyDefined, years= &acsyr. );
	%Pct_calc( var=PctPoorChildren, label=% children in poverty, num=PopPoorChildren, den=ChildrenPovertyDefined, years=&acsyr. );
	%Pct_calc( var=PctPoorElderly, label=% seniors in poverty, num=PopPoorElderly, den=ElderlyPovertyDefined, years=&acsyr. );

	%Moe_prop_a( var=PctPoorPersons_m_&acsyr., mult=100, num=PopPoorPersons_&acsyr., den=PersonsPovertyDefined_&acsyr., 
                       num_moe=mPopPoorPersons_&acsyr., den_moe=mPersonsPovertyDefined_&acsyr., label_moe = Poverty rate (%) &y_lbl. MOE );
    %Moe_prop_a( var=PctPoorChildren_m_&acsyr., mult=100, num=PopPoorChildren_&acsyr., den=ChildrenPovertyDefined_&acsyr., 
                       num_moe=mPopPoorChildren_&acsyr., den_moe=mChildrenPovertyDefined_&acsyr., label_moe = % children in poverty &y_lbl. MOE );     
    %Moe_prop_a( var=PctPoorElderly_m_&acsyr., mult=100, num=PopPoorElderly_&acsyr., den=ElderlyPovertyDefined_&acsyr., 
                       num_moe=mPopPoorElderly_&acsyr., den_moe=mElderlyPovertyDefined_&acsyr., label_moe = % seniors in poverty &y_lbl. MOE );


	%Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=&acsyr. )

	%dollar_convert( AvgFamilyIncome_&acsyr., AvgFamilyIncAdj_&acsyr., &acs_infl_yr., &inc_dollar_yr. );

	AvgFamilyIncome_m_&acsyr. = 
      %Moe_ratio( num=AggFamilyIncome_&acsyr., den=NumFamilies_&acsyr., 
                  num_moe=mAggFamilyIncome_&acsyr., den_moe=mNumFamilies_&acsyr. );

	%dollar_convert( AvgFamilyIncome_m_&acsyr., AvgFamilyIncAdj_m_&acsyr., &acs_infl_yr., &inc_dollar_yr )

	label AvgFamilyIncAdj_&acsyr. = "Avg. family income, &y_lbl."
		  AvgFamilyIncAdj_m_&acsyr. = "Avg. family income, &y_lbl. MOE"
;

	keep geo2010_nf geo2010 start_date end_date timeframe
		 PctPoorPersons_&acsyr. PctPoorChildren_&acsyr. PctPoorElderly_&acsyr. AvgFamilyIncAdj_&acsyr. 
	     PctPoorPersons_m_&acsyr. PctPoorChildren_m_&acsyr. PctPoorElderly_m_&acsyr. AvgFamilyIncAdj_m_&acsyr. ;

	rename PctPoorPersons_&acsyr. = PctPoorPersons
	 	   PctPoorChildren_&acsyr. = PctPoorChildren
		   PctPoorElderly_&acsyr. = PctPoorElderly
		   AvgFamilyIncAdj_&acsyr. = AvgFamilyIncAdj
		   PctPoorPersons_m_&acsyr. = PctPoorPersons_m
		   PctPoorChildren_m_&acsyr. = PctPoorChildren_m
		   PctPoorElderly_m_&acsyr. = PctPoorElderly_m
		   AvgFamilyIncAdj_m_&acsyr. = AvgFamilyIncAdj_m
;

run;


%macro ncdbloop (ncdbyr);

data Ncdb_&ncdbyr._income;
	length timeframe $ 15;
	set ncdb.Ncdb_sum_was15_tr10;

	/* Unformatted tract ID */
	GEO2010_nf = geo2010;

	/* County ID */
	ucounty=substr(geo2010,1,5);

	/* ACS timeframe */
	timeframe = "&ncdbyr" ;

	/* Populate start and end dates */
	%if &ncdbyr. = 1990 %then %do;
	start_date = '01jan90'd;
	end_date = '31dec90'd;
	%end;

	%else %if &ncdbyr. = 2000 %then %do;
	start_date = '01jan00'd;
	end_date = '31dec00'd;
	%end;

	format start_date end_date date9. ;

	/* Keep tracts in the MSA */
	%define_dcmetro (countyvar = ucounty);

    %Pct_calc( var=PctPoorPersons, label=Poverty rate (%), num=PopPoorPersons, den=PersonsPovertyDefined, years= &ncdbyr. );
	%Pct_calc( var=PctPoorChildren, label=% children in poverty, num=PopPoorChildren, den=ChildrenPovertyDefined, years=&ncdbyr. );
	%Pct_calc( var=PctPoorElderly, label=% seniors in poverty, num=PopPoorElderly, den=ElderlyPovertyDefined, years=&ncdbyr. );

	%Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=&ncdbyr. )

	%dollar_convert( AvgFamilyIncome_&ncdbyr., AvgFamilyIncAdj_&ncdbyr., &acs_infl_yr., &inc_dollar_yr. );


	label AvgFamilyIncAdj_&ncdbyr. = "Avg. family income, &ncdbyr."
;

	keep geo2010_nf geo2010 start_date end_date timeframe
		 PctPoorPersons_&ncdbyr. PctPoorChildren_&ncdbyr. PctPoorElderly_&ncdbyr. AvgFamilyIncAdj_&ncdbyr. ;

	rename PctPoorPersons_&ncdbyr. = PctPoorPersons
	 	   PctPoorChildren_&ncdbyr. = PctPoorChildren
		   PctPoorElderly_&ncdbyr. = PctPoorElderly
		   AvgFamilyIncAdj_&ncdbyr. = AvgFamilyIncAdj
;


run;

%mend ncdbloop;
%ncdbloop (1990);
%ncdbloop (2000);



data change_income;
	merge acs_all ncdb.Ncdb_sum_was15_tr10;
	by geo2010;

	%Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=1990 2000 &acsyr. )

	%dollar_convert( AvgFamilyIncome_1990, AvgFamilyIncAdj_1990, 1990, &inc_dollar_yr. );
	%dollar_convert( AvgFamilyIncome_2000, AvgFamilyIncAdj_2000, 2000, &inc_dollar_yr. );
	%dollar_convert( AvgFamilyIncome_&acsyr., AvgFamilyIncAdj_&acsyr., &acs_infl_yr., &inc_dollar_yr. );

	 if AvgFamilyIncAdj_1990 > 0 then PctChgAvgFamilyIncAdj_1990_2000 = %pctchg( AvgFamilyIncAdj_1990, AvgFamilyIncAdj_2000 );
	 if AvgFamilyIncAdj_2000 > 0 then PctChgAvgFamilyIncA_2000_&acsyr. = %pctchg( AvgFamilyIncAdj_2000, AvgFamilyIncAdj_&acsyr. );

run;


data change_income_1990_2000;
	length timeframe $ 15;
	set change_income;

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

	PctChgAvgFamilyIncAdj = PctChgAvgFamilyIncAdj_1990_2000;
	keep geo2010_nf geo2010 start_date end_date timeframe PctChgAvgFamilyIncAdj;
run;


data change_income_2000_ACS;
	length timeframe $ 15;
	set change_income;

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

	PctChgAvgFamilyIncAdj = PctChgAvgFamilyIncA_2000_&acsyr.;
	keep geo2010_nf geo2010 start_date end_date timeframe PctChgAvgFamilyIncAdj;
run;


proc sort data = Tanf_sum_tr10_long_allyr; by geo2010_nf; run;
proc sort data = Fs_sum_tr10_long_allyr; by geo2010_nf; run;

data tanf_fs;
	merge Tanf_sum_tr10_long_allyr Fs_sum_tr10_long_allyr;
	by geo2010_nf;
run;


data income_tr10;
	set acs_income ncdb_2000_income ncdb_1990_income change_income_2000_ACS change_income_1990_2000 tanf_fs;

	/* County ID */
	ucounty=substr(geo2010,1,5);
	drop ucounty;

	%indc_flag (countyvar = ucounty);

	label PctPoorPersons = "Poverty rate (%)"
		  PctPoorChildren = "% children in poverty"
		  PctPoorElderly = "% seniors in poverty"
		  AvgFamilyIncAdj = "Avg. family income"
		  PctPoorPersons_m = "Poverty rate (%) MOE"
		  PctPoorChildren_m = "% children in poverty MOE"
		  PctPoorElderly_m = "% seniors in poverty MOE"
		  AvgFamilyIncAdj_m = "AvgFamilyIncAdj MOE"
		  PctChgAvgFamilyIncAdj = "% change in avg. family income"
		  ;
run;


/* Create metadata for the dataset */
proc contents data = income_tr10 out = income_tr10_metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&metadatafile.";
	proc print data =income_tr10_metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&datafile.";
	proc print data =income_tr10 noobs;
	run;
ods csv close;


%mend export_income;



/* End Macro */
