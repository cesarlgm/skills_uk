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

gstats winsor d_l_employment, cuts(2 98) generate(d_l_employment_w) 
gstats winsor d_l_employment, cuts(5 95) generate(d_l_employment_5) 
gstats winsor d_l_employment, cuts(20 80) generate(d_l_employment_20)  


*Now I add the employment share data
merge m:1 occupation year using  `indexes'

*Compute sum of skills
egen tot_skill=rowtotal($index_list)

*I force the skills to sum to 1
foreach variable in $index_list  {
    generate i_`variable'=`variable' // tot_skill
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



egen industry_id=group(industry_cw education)


eststo clear

reghdfe d_l_employment_w  *1 *2 *3 , nocons absorb(industry_id) vce(cl occupation)
eststo regu

forvalues educ=1/3 {
    foreach variable in $index_list {
        est restore regu
        nlcom _b[`variable'`educ']/(_b[`variable'1]-_b[manual1]+_b[manual`educ']), post 
        eststo theta`variable'`educ'u
    }
}
/*
local stat_list 
forvalues educ=1/3 {
    foreach variable in $index_list {
        local stat_list  `stat_list' theta_`variable'`educ'=(_b[`variable'`educ']/(_b[`variable'1]-_b[manual1]+_b[manual`educ']))
    
    }
}

bootstrap `stat_list', reps(1000): reghdfe d_l_employment  *1 *2 *3, nocons absorb(industry_id) vce(r)
*/

reghdfe d_l_employment_w  *1 *2 *3 [aw=obs], nocons absorb(industry_id) vce(cl occupation)
eststo regw

forvalues educ=1/3 {
    foreach variable in $index_list {
        est restore regw
        nlcom _b[`variable'`educ']/(_b[`variable'1]-_b[manual1]+_b[manual`educ']), post 
        eststo theta`variable'`educ'w
    }
}


local table_name "results/tables/regression_table.tex"
local table_title "Estimates of $\beta_{i}^e$"
local table_note   "Standard errors clustered at the occupation level. Estimates include industry by education fixed-effects"
local table_options   label append f collabels(none) ///
        nomtitles plain  par  b(%9.3fc) se(%9.3fc) star
local col_titles Unweighted Weighted 

textablehead using `table_name', ncols(2) coltitles(`col_titles') ///
    title(`table_title')

leanesttab reg*u reg*w using `table_name', fmt(2) ///
    stat(n_occupations N r2, fmt(%9.0fc %9.0fc %9.2fc)) append
    
textablefoot using `table_name', notes(`table_note')


local table_name "results/tables/theta_estimates.tex"
local table_title "Estimates of $\theta_{i}^e$"
local table_note   "standard errors computed using the delta method"
local table_options   label append f collabels(none) ///
        nomtitles plain  par  b(%9.3fc) se(%9.3fc) star
local col_titles Manual Routine Abstract Social Manual Routine Abstract Social

textablehead using `table_name', ncols(8) coltitles(`col_titles') ///
    exhead(&\multicolumn{4}{c}{Unweighted}&\multicolumn{4}{c}{Weighted} \\) ///
    title(`table_title')

leanesttab theta*1u theta*1w using `table_name', fmt(2) noobs append  coeflabel(_nl_1 "Low")
leanesttab theta*2u theta*2w using `table_name', fmt(2) noobs append  coeflabel(_nl_1 "Mid")
leanesttab theta*3u theta*3w using `table_name', fmt(2) noobs append  coeflabel(_nl_1 "High")
textablefoot using `table_name', notes(`table_note')

