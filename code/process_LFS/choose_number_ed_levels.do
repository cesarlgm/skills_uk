set graphics on 

grscheme, ncolor(7) style(tableau)
grstyle set lpattern solid dash dash_dot shortdash shortdash_dot 
grstyle set linewidth medthick
use "./data/temporary/LFS_agg_database", clear


preserve
    generate employment=1
    collapse (mean) l_hourpay (sum) people [aw=people], by(edlevLFS year)

    egen temp=sum(people), by(year)
    generate emp_share=people/temp 


    local y_var l_hourpay
    tw  (line `y_var'  year if edlev==0) ///
        (line `y_var'  year if edlev==1) ///
        (line `y_var'  year if edlev==2) ///
        (line `y_var'  year if edlev==3) ///
        (line `y_var'  year if edlev==4) if year>2001, ///
        legend(order(1 "No qualification" 2 "GCSE D-G" 3 "GCSE A-C" ///
    4 "A* level" 5 "Bachelor +") pos(6)) 
    graph export "results/figures/average_wages_by_education.png", replace

    
    local y_var emp_share
    tw  (line `y_var'  year if edlev==0) ///
        (line `y_var'  year if edlev==1) ///
        (line `y_var'  year if edlev==2) ///
        (line `y_var'  year if edlev==3) ///
        (line `y_var'  year if edlev==4) if year>2001, ///
        legend(order(1 "No qualification" 2 "GCSE D-G" 3 "GCSE A-C" ///
    4 "A* level" 5 "Bachelor +") pos(6)) 
    graph export "results/figures/emp_share_by_education.png", replace
restore


egen total_employment=sum(people), by(year edlevLFS)

generate emp_share=people/total_employment


local year_list 2001 2005 2010 2017

forvalues year=2001/2017 { 
 tw (lowess emp_share l_hourpay if edlevLFS==0,   ) ///
    (lowess emp_share l_hourpay if edlevLFS==1,   ) ///
    (lowess emp_share l_hourpay if edlevLFS==2,   ) ///
    (lowess emp_share l_hourpay if edlevLFS==3,   ) ///
    (lowess emp_share l_hourpay if edlevLFS==4,   ) ///
    if year==`year', ///
    legend(order(1 "No qualification" 2 "GCSE D-G" 3 "GCSE A-C" ///
    4 "A* level" 5 "Bachelor +") pos(6)) ///
    xtitle("log(hourly pay)") ///
    title(`year')
    graph export "results/figures/education_shares_`year'.png", replace
}

keep emp_share bsoc00Agg year edlevLFS
reshape wide emp_share, i(bsoc00Agg year) j(edlevLFS)
foreach variable of varlist emp_share0-emp_share4 { 
    replace `variable'=0 if missing(`variable')
}

cap log close
log using "results/log_files/employment_share_corr.txt", text replace

di "all years"
pwcorr emp_share0-emp_share4

foreach year in 2001 2003 2005 2010 2017 { 
    di "`year'"
    pwcorr emp_share0-emp_share4 if year==`year'
}
log close

*I am inclined to keep A*, the bottom three and bachelor+

