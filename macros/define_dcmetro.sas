/**************************************************************************
 Program:  define_dcmetro
 Library:  Web
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/08/2018
 Version:  SAS 9.4
 Environment:  Windows
 Description: Macro to define counties in the Metro area
 Modifications: 

**************************************************************************/

%macro define_dcmetro (countyvar);

if &countyvar. in (
"11001", /* District of Columbia */
"24009", /* Calvert */
"24017", /* Charles */
"24021", /* Frederick */
"24031", /* Montgomery */
"24033", /* Prince George's */
"51013", /* Arlington */
"51043", /* Clarke */
"51047", /* Culpeper */
"51059", /* Fairfax */
"51061", /* Fauquier */
"51107", /* Loudoun */
"51153", /* Prince William */
"51157", /* Rappahannock */
"51177", /* Spotsylvania */
"51179", /* Stafford */
"51187", /* Warren */ 
"51510", /* Alexandria */
"51600", /* Fairfax */
"51610", /* Falls Church */
"51630", /* Fredericksburg */
"51683", /* Manassas */
"51685", /* Manassas Park */
"54037" /* Jefferson */
);

%mend define_dcmetro;


/*End Macro */
