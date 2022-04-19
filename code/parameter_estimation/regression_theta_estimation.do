global normalization .000001

*New regression approach

*Creating the SES database
do "code/process_SES/save_file_for_minimization.do"
do "code/process_SES/compute_skill_indexes.do"


rename educ_3_low education
rename $occupation occupation

*Collapsing the dataset
gcollapse (mean) $index_list (count) obs=chands, by(occupation year education)
    
*Dropping observations that I don't need
drop if year==1997

*Setting panel dataset
{
    egen group_id=group(occupation education)
    egen time=group(year)

    xtset group_id time
}

*Creating log and dlog of skills
foreach index in $index_list {
    generate l_`index'=asinh(`index')
    generate d_l_`index'=d.l_`index'
}

*gstats winsor d_l_*, cut(20 80) replace

drop if year==2001


foreach index in $index_list {
    generate  y_d_l_`index'=d_l_`index'-d_l_manual
}

*Computing averages by year
foreach index in manual social routine abstract {    
    egen pi_`index'=mean(y_d_l_`index') if !missing(y_d_l_`index'), by(occupation year)

    generate y_`index'=d_l_`index'+ pi_`index'
}


generate x_manual=  manual*pi_manual
generate x_social=  social*pi_social
generate x_routine= routine*pi_routine
generate x_abstract=abstract*pi_abstract


gstats winsor y_* x_*, cut(15 95) replace

keep occupation education year y_* x_*  $index_list pi_*
rename (y_manual y_social y_abstract y_routine) (y_1 y_2 y_3 y_4)
reshape long y_, i(occupation education year)  j(skill)

eststo clear
foreach index in $index_list {
    eststo reg: regress y_ i.education#c.x_manual i.education#c.x_social i.education#c.x_routine i.education#c.x_abstract , nocons vce(cl occupation)
}

generate skill_sum=.
forvalues education=1/3 {
    local social`education':    display %9.2fc      _b[`education'.education#c.x_social]
    local abstract`education':  display %9.2fc      _b[`education'.education#c.x_abstract]
    local routine`education':   display %9.2fc      _b[`education'.education#c.x_routine]
    replace skill_sum=_b[`education'.education#c.x_social]*social+_b[`education'.education#c.x_abstract]*abstract+_b[`education'.education#c.x_routine]*routine if education==`education'
}

generate y_skill_sum=1-skill_sum

eststo manual: regress y_skill_sum ibn.education#c.manual if skill==1, nocons vce(cl occupation)

forvalues education=1/3{
    local manual`education':    display %9.2fc      _b[`education'.education#c.manual]
}

matrix costs=J(3,4,.)
forvalues education=1/3 {
    local counter=1
    foreach skill in manual routine social abstract {
        matrix costs[`education',`counter']=``skill'`education''
        local ++counter
    }
}

matrix colnames costs=manual routine social abstract
matrix rownames costs=Low Mid High
matrix list costs

*Pi stats
{
    label var pi_routine    "Routine"
    label var pi_abstract   "Abstract"
    label var pi_social     "Social"
    estpost tabstat pi_routine pi_abstract pi_social, stat(mean sd p25 p75) columns(stat)

    local   table_name "results/tables/pi_variation_global.tex"
    local   table_title "Variation of $\pi_{jt}$ across education"
    esttab . using `table_name', ///
        cells("mean(fmt(2)) sd(fmt(2)) p25(fmt(2)) p75(fmt(2))") ///
        unstack label booktabs nomtitles replace ///
        title(`table_title')
}


local   table_name "results/tables/theta_estimates.tex"
local   table_title "$\theta\_{ie}$ estimates"
esttab matrix(costs, fmt(2)) using `table_name', ///
    replace booktabs title(`table_title')


/*

*This thing really doesn't make sense
{
    foreach variable of varlist pi_* {
        eststo `variable'_raw: regress `variable' i.education, vce(r)
        eststo `variable'_net: reghdfe `variable' i.education, absorb(occupation) vce(r)
    }


    local   table_name "results/tables/pi_variation.tex"
    local   table_title "Variation of $\pi_{jt}$ across education"
    global  column_title Routine Abstract Social Routine Abstract Social 

    textablehead using `table_name', ncols(6) title(`table_title') coltitles($column_title)
    estfe *_net, labels(occupation "Occupation FE")
    leanesttab pi_routine_raw pi_abstract_raw pi_social_raw pi_routine_net pi_abstract_net pi_social_net ///
        using `table_name', ///
        omit nobase fmt(2) indicate(`r(indicate_fe)') stat(N r2) append
    textablefoot using `table_name'
} 
/*

reghdfe d_l_employment_w  *1 *2 *3 , nocons absorb(industry_id) vce(cl occupation)
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

