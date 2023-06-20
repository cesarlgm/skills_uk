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


*I set up filters to keep the number of occupations consistent across files
{ 
    *Including only jobs I have observations for
    use "data/additional_processing/gmm_skills_dataset", clear

    cap drop temp
    *Filtering by number of education levels in the job
    gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
    egen n_educ=max(temp), by(occupation year)
    keep if n_educ==3

    *keep if inlist(occupation, 1121,1122,1131, 1135)

    drop if missing(y_var)
    sort equation occupation year education


    egen n_obs=count(manual) if equation==1, by(occupation year)

    drop if n_obs==4


    keep occupation 

    duplicates drop 

    tempfile job_filter
    save `job_filter'

}

{
    use "data/additional_processing/gmm_employment_dataset", clear

    drop if missing(y_var)
    keep if equation==3

    *Checking number of times I observe the job
    egen n_times_n=count(year), by(occupation education education_d)
    egen n_times_d=count(year), by(occupation education education_d)

    keep if n_times_d==3&n_times_d==3

    keep occupation
    duplicates drop 

    tempfile employment_filter
    save `employment_filter'
}



use "data/temporary/filtered_dems_SES", clear
drop if missing(gwtall)

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

rename $education education
rename bsoc00Agg occupation

*merge m:1 occupation using `job_filter', keep(3) nogen 
*merge m:1 occupation using `employment_filter', keep(3) nogen 

do "code/process_SES/compute_skill_indexes.do"


eststo clear
foreach index in $index_list {
	eststo `index'r: reghdfe `index' i.education, absorb(year) vce(cl occupation)
	eststo `index'n: reghdfe `index' i.education, absorb(year occupation) vce(cl occupation)
}

/*
esttab *r, se
esttab *n, se

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

