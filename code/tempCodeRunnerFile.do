clear all
clear matrix
set more off, permanently
set graphics off
capture log close 
graph set window fontface "Times New Roman"

set maxvar 120000
set scheme s1color, permanently

cd "C:\Users\thecs\Dropbox (Boston University)\boston_university\8-Research Assistantship\ukData"

global education educ_3_low
global occupation bsoc00Agg
global wage_cuts  10 90
global continuous_list grossPay grossWkPayMain hourpay al_wkpay al_hourpay
global index_list   manual social routine abstract 

adopath + "code/parameter_estimation"
