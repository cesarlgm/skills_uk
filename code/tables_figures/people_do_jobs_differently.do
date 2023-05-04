*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	regressions tables focussing on different measures of routine 
				pc use.
	
	output: skill_use_within_jobs

*/
*===============================================================================
*===============================================================================

global education educ_3_low

use "data/temporary/filtered_dems_SES", clear
drop if missing(gwtall)

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

rename $education education
rename bsoc00Agg occupation


do "code/process_SES/compute_skill_indexes.do"


eststo clear
foreach index in $index_list {
	eststo `index'r: reghdfe `index' i.education, absorb(year) vce(cl occupation)
	eststo `index'n: reghdfe `index' i.education, absorb(year occupation) vce(cl occupation)
}


esttab *r 
esttab *n

label define education 1 "HS dropouts" 2 "HG graduates" 3 "College+"
label values education education

local table_name "results/tables/skill_use_within_jobs.tex"
local table_title "Within-job skill use across education groups"
local coltitles `""Manual""Social""Adabtability""Abstract""'
local table_notes "standard errors clustered at the occupation level in parenthesis"

textablehead using `table_name', ncols(4) coltitles(`coltitles') title(`table_title')
leanesttab *n using `table_name', fmt(3) append star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") nobase stat(N, label( "\midrule Observations") fmt(%9.0fc))
texspec using `table_name', spec(y y y y) label(Occupation f.e.)
texspec using `table_name', spec(y y y y) label(Year f.e.)
textablefoot using `table_name', notes(`table_notes')

*Excel table
esttab *n using "results/tables/skill_use_within_jobs.csv", ///
	 b(3) se(3) par  star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") label nobase stat(N, label( "Observations") fmt(%9.3fc)) replace

