*=====================================================================================
*MAIN DO FILE

*Description: this do file executes all the programs required for the paper
*Author: César Garro-Marín
*=====================================================================================
/*
	To add later
	gtools
	unique

*/

*=====================================================================================

clear all
clear matrix
set more off, permanently
set graphics off
capture log close 
graph set window fontface "Times New Roman"

set maxvar 120000
set scheme s1color, permanently

cd "C:\Users\thecs\Dropbox\\1_boston_university\8-Research Assistantship\ukData"

global education educ_3_low //educ_3_low
global occupation bsoc00Agg
global wage_cuts  10 90
global continuous_list grossPay grossWkPayMain hourpay al_wkpay al_hourpay
global index_list   manual social routine 

adopath + "code/parameter_estimation"

