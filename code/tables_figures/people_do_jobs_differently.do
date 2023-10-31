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
local def `1'


global education educ_3_low

*BROADER SET OF OCCUPATIONS
{
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

    do "code/process_SES/compute_skill_indexes.do" `def'


    eststo clear
    foreach index in $index_list abstract`def' {
        eststo `index'r: reghdfe `index' i.education [aw=gwtall], absorb(year) vce(cl occupation)
        unique occupation
        estadd scalar n_occ=`r(unique)', replace
        eststo `index'r
        eststo `index'n: reghdfe `index' i.education [aw=gwtall], absorb(year occupation) vce(cl occupation)
        unique occupation
        estadd scalar n_occ=`r(unique)', replace
        eststo `index'n
    }


    esttab *r, se
    esttab *n, se

    
    label define education 1 "HS dropouts" 2 "HG graduates" 3 "College+"
    label values education education

    local table_name "results/tables/people_do_jobs_differently_all.tex"
    local table_title "Within-job skill use across education groups"
    local coltitles `""Manual""Social""Adabtability""Abstract""'
    local table_notes "standard errors clustered at the occupation level in parenthesis"

    textablehead using `table_name', ncols(4) coltitles(`coltitles') title(`table_title')
    leanesttab *n using `table_name', fmt(3) append star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") nobase stat(n_occ N , label( "\midrule Number of occupations" "Observations") fmt(%9.0fc %9.0fc))
    texspec using `table_name', spec(y y y y) label(Occupation f.e.)
    texspec using `table_name', spec(y y y y) label(Year f.e.)
    textablefoot using `table_name', notes(`table_notes')

    *Excel table
    esttab *n using "results/tables/skill_use_within_jobs_all.csv", ///
        b(3) se(3) par  star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") label nobase stat(n_occ N , label( "\midrule Number of occupations" "Observations") fmt(%9.3fc %9.3fc)) replace
}

/*
*OCCUPATIONS FILTERED TO THETA ESTIMATES OCCUPATIONS
{
    use "data/temporary/filtered_dems_SES", clear
    drop if missing(gwtall)

    rename edlev edlevLFS
    do "code/process_LFS/create_education_variables.do"


    do "code/aggregate_SOC2000.do"

    merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

    keep if  n_years==4

    rename $education education
    rename bsoc00Agg occupation

    merge m:1 occupation using "data/additional_processing/GMM_occupation_filter", keep(3)


    do "code/process_SES/compute_skill_indexes.do"


    eststo clear
    foreach index in $index_list {
        eststo `index'r: reghdfe `index' i.education [aw=gwtall], absorb(year) vce(cl occupation)
        unique occupation
        estadd scalar n_occ=`r(unique)', replace
        eststo `index'r
        eststo `index'n: reghdfe `index' i.education [aw=gwtall], absorb(year occupation) vce(cl occupation)
        unique occupation
        estadd scalar n_occ=`r(unique)', replace
        eststo `index'n
    }


    esttab *r, se
    esttab *n, se


    label define education 1 "HS dropouts" 2 "HG graduates" 3 "College+"
    label values education education

    local table_name "results/tables/people_do_jobs_differently.tex"
    local table_title "Within-job skill use across education groups"
    local coltitles `""Manual""Social""Adabtability""Abstract""'
    local table_notes "standard errors clustered at the occupation level in parenthesis"

    textablehead using `table_name', ncols(4) coltitles(`coltitles') title(`table_title')
    leanesttab *n using `table_name', fmt(3) append star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") nobase stat(n_occ N , label( "\midrule Number of occupations" "Observations") fmt(%9.0fc %9.0fc))
    texspec using `table_name', spec(y y y y) label(Occupation f.e.)
    texspec using `table_name', spec(y y y y) label(Year f.e.)
    textablefoot using `table_name', notes(`table_notes')

    *Excel table
    esttab *n using "results/tables/skill_use_within_jobs.csv", ///
        b(3) se(3) par  star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") label nobase stat(n_occ N , label( "\midrule Number of occupations" "Observations")  fmt(%9.3fc %9.0fc)) replace
}
