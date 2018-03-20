/**************************************************************************
 Program:  web_formats
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/20/2018
 Version:  SAS 9.4
 Environment:  Windows
 Description: Formats for web files.
 Modifications: 

**************************************************************************/

%macro web_formats;

/* County names */
proc format;
	value $profile_cnty

"11001" = "District of Columbia"
"24009" = "Calvert"
"24017" = "Charles"
"24021" = "Frederick"
"24031" = "Montgomery"
"24033" = "Prince George's"
"51013" = "Arlington"
"51043" = "Clarke"
"51047" = "Culpeper"
"51059" = "Fairfax"
"51061" = "Fauquier"
"51107" = "Loudoun"
"51153" = "Prince William"
"51157" = "Rappahannock"
"51177" = "Spotsylvania"
"51179" = "Stafford"
"51187" = "Warren" 
"51510" = "Alexandria"
"51600" = "Fairfax"
"51610" = "Falls Church"
"51630" = "Fredericksburg"
"51683" = "Manassas"
"51685" = "Manassas Park"
"54037" = "Jefferson"
;
run;

/* Rounding */
proc format;
    picture profnum (default=12 round)
      -9999999999, .i = 'i' (noedit)
      -9999999998, .s = 's' (noedit)
      -999999999 - -10 = '000,000,009' (prefix='-')
      -10 <-< 0 = '009.9' (prefix='-')
       0   -<10 = '009.9'
      10 - high = '000,000,009' ;
run;


%mend web_formats;


/*End Macro */
