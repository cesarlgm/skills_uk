*========================================================
*GETTING TOP AND BOTTOM JOBS BY SKILL
*========================================================

/*
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

*/


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

gcollapse (mean) $index_list [fw=gwtall], by(occupation)

*merge m:1 occupation using `job_filter', keep(3) nogen 
*merge m:1 occupation using `employment_filter', keep(3) nogen 


*Getting top and bottom jobs by skill
foreach skill in $index_list {
    preserve
    gsort -`skill'
    keep if inrange(_n,1,5)|inrange(_n,_N-4,_N)
    export delimited occupation using "results/tables/occ_examples_`skill'", replace
    restore
}


