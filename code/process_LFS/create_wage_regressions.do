global education educ_3_low


frames reset

*Pre-regression cleaning
{
	use "data/temporary/LFS_agg_database", clear

	do "code/process_LFS/create_education_variables.do"

	generate temp=1

    replace year=2001 if inlist(year,2001,2002,2003)
    replace year=2017 if inlist(year,2015,2016,2017)

    keep if inlist(year,2001,2017)

	gcollapse (mean) grossWkPayMain hourpay al_* l_hourpay l_wkpay l_gpay (sum) temp [fw=people], by($occupation year $education industry_cw)

    rename temp people

    egen obs_id=group($occupation $education industry_cw)
    egen time_counter=group(year)

    xtset obs_id time_counter

    foreach variable of varlist l_* al_* {
        generate d_`variable'=d.`variable'
    }

    generate temp=l.people
    replace people=temp
    drop temp

    
    drop if year==2001
    /*
    replace year=2001 if year==2006
    replace year=2006 if year==2012
    replace year=2012 if year==2017
    */
    replace year=2001 if year==2017 
    *Adding SES information
    {
        frame create SES_occs
        frame change SES_occs
        do "code/process_SES/save_file_for_minimization.do"

        do "code/process_SES/compute_skill_indexes.do"

        gcollapse (mean)  $index_list (count) obs=chands (sum) wobs=gwtall, by($occupation $education year) 

        tempfile SES_data
        save `SES_data'
    }

    frame change default
    merge m:1 $occupation $education year using `SES_data', keep(3) nogen
}

gstats winsor d_*, replace cut(20 80)

eststo clear
foreach income of varlist d_* {
    eststo w_`income': reghdfe `income' i.$education#c.($index_list) [aw=obs], absorb($occupation industry_cw)  vce(r)
    foreach index in $index_list {
        est restore w_`income'
        nlcom _b[3.$education#`index']/_b[1.$education#`index'], post
        eststo w_th_`index'_`income'
        est restore w_`income'
        nlcom _b[2.$education#`index']/_b[1.$education#`index'], post
        eststo w_tm_`index'_`income'        
    }
    eststo `income': reghdfe `income' i.$education#c.($index_list) , absorb($occupation industry_cw)  vce(r)
    foreach index in $index_list {
        est restore `income'
        nlcom _b[3.$education#`index']/_b[1.$education#`index'], post
        eststo th_`index'_`income'
        est restore `income'
        nlcom _b[2.$education#`index']/_b[1.$education#`index'], post
        eststo tm_`index'_`income'        
    }
}

label var d_l_hourpay   "log average hourly pay"
label var d_l_gpay      "log average gross pay"
label var d_l_wkpay     "log average weekly pay"

label var d_al_hourpay   "average log hourly pay"
label var d_al_wkpay     "average log weekly pay"

foreach income of varlist d_* {
    local title: variable label `income'
    local table_name    "results/tables/theta_wage_`income'.tex"
    local table_title   "$ \theta $ estimates, `title'"
    local table_note    Robust standard errors in parenthesis. Columns 1 to 4 weighted by LFS-cell size
    local coltitles Manual Routine Social Abstract Manual Routine Social Abstract

    textablehead using `table_name', ncols(8) coltitles(`coltitles') title(`table_title') exhead("& \multicolumn{4}{c}{Weighted} & \multicolumn{4}{c}{Unweighted} \\")
    leanesttab  w_th_manual_`income' w_th_routine_`income' w_th_social_`income' w_th_abstract_`income' th_manual_`income' th_routine_`income' th_social_`income' th_abstract_`income' using `table_name', append noobs coeflabel(_nl_1 "High") 
    leanesttab  w_tm_manual_`income' w_tm_routine_`income' w_tm_social_`income' w_tm_abstract_`income' tm_manual_`income' tm_routine_`income' tm_social_`income' tm_abstract_`income' using `table_name', append coeflabel(_nl_1 "Mid") 
    textablefoot using `table_name', notes(`table_note')
}
/*
*Computing regressions
{
    forvalues educ in $index_list {
        reghdfe `index' 
    }
}