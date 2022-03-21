frames reset

clear 
use "data/additional_processing/regression_wage_dataset"
append using "data/additional_processing/regression_employment_dataset"

{
    frame create SES_occs
    frame change SES_occs
    do "code/process_SES/save_file_for_minimization.do"

    do "code/process_SES/compute_skill_indexes.do"

    generate ses_obs=1

    gcollapse (mean)  $index_list (count) ses_obs, by($occupation $education year) 

    rename $occupation occupation
    rename $education education

    tempfile SES_data
    save `SES_data'
}


frame change default
merge m:1 occupation education year using `SES_data', keep(3) nogen

order occupation year education $index_list, first
sort database occupation education

forvalues educ=1/3 { 
    foreach index in $index_list {
        generate i_`index'`educ'=`index' if education==`educ'
        replace i_`index'`educ'=0 if education!=`educ'
    }
}

xi i.occupation, prefix(o_)

foreach variable of varlist o_*  {
    replace `variable'=0 if database==1
}

eststo clear

global y_list d_l_hourpay d_l_wkpay d_l_gpay

foreach income of varlist $y_list {
    cap drop y_var
    generate y_var=d_l_employment   if database==1
    replace y_var=d_l_wkpay if database==2

    gstats winsor y_var, cut(20 80) replace by(database)

    regress y_var i_* o_*, vce(cl occupation)

    eststo w_`income': regress `income' i_* o_* [aw=weight],   vce(r)
    foreach index in $index_list {
        est restore w_`income'
        nlcom _b[i_`index'3]/_b[i_`index'1], post
        eststo w_th_`index'_`income'
        est restore w_`income'
        nlcom _b[i_`index'2]/_b[i_`index'1], post
        eststo w_tm_`index'_`income'        
    }
    eststo `income':  regress `income' i_* o_* ,  vce(r)
    foreach index in $index_list {
        est restore `income'
        nlcom _b[i_`index'3]/_b[i_`index'1], post
        eststo th_`index'_`income'
        est restore `income'
        nlcom _b[i_`index'2]/_b[i_`index'1], post
        eststo tm_`index'_`income'                
    }
}

label var d_l_hourpay   "log average hourly pay"
label var d_l_gpay      "log average gross pay"
label var d_l_wkpay     "log average weekly pay"

foreach income of varlist $y_list {
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