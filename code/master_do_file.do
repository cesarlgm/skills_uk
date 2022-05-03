clear all
clear matrix
set more off, permanently
set graphics off
capture log close 
graph set window fontface "Times New Roman"

set maxvar 23767 
set scheme s1color, permanently

cd "C:\Users\thecs\Dropbox (Boston University)\boston_university\8-Research Assistantship\ukData"

global education educ_3_mid
global occupation bsoc00Agg
global wage_cuts  10 90
global continuous_list grossPay grossWkPayMain hourpay al_wkpay al_hourpay


*===============================================================================
*RECONSTRUCTING THE EDUCATIONAL CLASSIFICATION
*===============================================================================
/*
*Recovering the mapping of edlev in the SES
do "code/reconstructionEdlev.do"

do "code/saveOccupationCrossWalks.do"
*/

*Process Labor Force Surveys
do "code/process_LFS/process_LFS_database.do" 

*do "code/process_SES/process_SES_database.do"


*===============================================================================
*Prepare and create regressions
*===============================================================================
do "code/parameter_estimation/prepare_regression_data.do"



/*
*===============================================================================
*WORKING WITH LFS DATA
*===============================================================================


*do "./codeFiles/checkingCrossWalkConsistency.do"


*===============================================================================
*WORKING WITH SES DATA
*===============================================================================
do "./codeFiles/2_handlingSES/processSESdata.do"  `occupation'  0 3 ///
	`aggregateSOC'  `educationType' `chosen_def' `fixed_def'

/*
*This runs occ distributions with weighted data
do "${directory}/codeFiles/exploratoryEdlev.do" 0


