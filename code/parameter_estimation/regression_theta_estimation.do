use  "data/additional_processing/final_SES_file.dta", clear

*First I compute the skill indexes
{
    local abstract 		cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
    local social		cpeople cteach  cspeech cpersuad cteamwk clisten
    local routine		brepeat bvariety cplanme bme4 
    local manual		chands cstrengt  cstamina
    global index_list 	manual abstract social routine  

    local variable_list  `manual' `routine' `abstract' `social' 

    foreach variable in `variable_list' {
        summ `variable'
        replace `variable'=(`variable'-`r(min)')/(`r(max)'-`r(min)')
        summ `variable'
        assert `r(min)'==0
        assert `r(max)'==1
    }

    foreach index in $index_list {
        egen `index'=rowmean(``index'')
    }

    gcollapse (mean) $index_list (count) obs=chands, by(occupation year education)
    
    tempfile indexes
    save `indexes'
}

use "data/additional_processing/final_LFS_file.dta"
*Now I add the employment share data
merge m:1 occupation year using  `indexes'

*Compute sum of skills
egen tot_skill=rowtotal($index_list)

*I force the skills to sum to 1
foreach variable in $index_list  {
    generate i_`variable'=`variable' / tot_skill
}

egen temp=rowtotal(i_*)

drop temp

global index_vars i_manual  i_routine i_abstract i_social

*Modifying to 
forvalues educ=1/3 {
    foreach variable in $index_list {
        generate `variable'`educ'=i_`variable'*(education==`educ')
    }
}




eststo clear
forvalues educ=1/3 {
    reghdfe d_l_employment  i_* if education==`educ', nocons absorb(industry_cw)
    
    unique occupation if education==`educ' 
    estadd scalar n_occupations=`r(unique)'
    
    eststo reg`educ'u
  
    foreach variable in $index_list {
        global `variable'_`educ'_u=_b[i_`variable']
    }

    reghdfe d_l_employment  i_* if education==`educ' [aw=obs], nocons absorb(industry_cw)
    unique occupation if education==`educ' 
    estadd scalar n_occupations=`r(unique)'
    eststo reg`educ'w

    foreach variable in $index_list {
        global `variable'_`educ'_w=_b[i_`variable']
    }
    
}


forvalues educ=1/3 {
    foreach variable in $index_list {
        global theta_`variable'_`educ'_u= ${`variable'_`educ'_u}/ (${`variable'_1_u}-$manual_1_u+${manual_`educ'_u})
        global theta_`variable'_`educ'_w= ${`variable'_`educ'_w}/ (${`variable'_1_w}-$manual_1_w+${manual_`educ'_w})
    }
}


*Write matrix here
matrix resultsu=J(3,4,.)
matrix resultsw=J(3,4,.)

forvalues educ=1/3 {
    local counter=1
    foreach variable in $index_list {
        matrix resultsu[`educ',`counter']=${theta_`variable'_`educ'_u}
        matrix resultsw[`educ',`counter']=${theta_`variable'_`educ'_w}
        local ++counter
    }
}


*Ok this doesn't work, but I don't know what to do about it. What about normalizing to 1?
matrix colnames resultsu= "Manual" "Routine" "Abstract" "Social"
matrix rownames resultsu= "Low" "Mid" "High"
log using "results/log_files/unweighted_thetas.txt", text replace
    matrix list resultsu
log close
matrix colnames resultsw= "Manual" "Routine" "Abstract" "Social"
matrix rownames resultsw= "Low" "Mid" "High"
log using "results/log_files/weighted_thetas.txt", text replace
    matrix list resultsw
log close


local table_name "results/tables/regression_table.tex"
local table_title "Estimates of $\beta_{i}^e$"
local table_options   label append f collabels(none) ///
        nomtitles plain  par  b(%9.3fc) se(%9.3fc) star
local col_titles Low Mid High Low Mid High 

textablehead using `table_name', ncols(6) coltitles(`col_titles') ///
    exhead(&\multicolumn{3}{c}{Unweighted}&\multicolumn{3}{c}{Weighted} \\) ///
    title(`table_title')

leanesttab reg*u reg*w using `table_name', fmt(2) ///
    stat(n_occupations N r2, fmt(%9.0fc %9.0fc %9.2fc)) append
    
textablefoot using `table_name'

