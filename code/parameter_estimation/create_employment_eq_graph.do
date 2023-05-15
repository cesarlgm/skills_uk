*Create equation three graph


*==========================================================================================
import excel "data\output\theta_estimates.xlsx", sheet("Sheet1") firstrow clear

drop code 
reshape wide theta, i(education) j(skill)


tempfile theta
save `theta'

import excel "data\output\theta_estimates.xlsx", sheet("Sheet1") firstrow clear

drop code 
rename theta theta_d
reshape wide theta, i(education) j(skill)

rename education education_d
tempfile theta_d
save `theta_d'


import excel "data\output\pi_estimates.xlsx", sheet("Sheet1") firstrow clear

drop code 
reshape wide pi, i(occupation year) j(skill)

tempfile pi
save `pi'



use "data/additional_processing/gmm_employment_dataset", clear

merge m:1 occupation year using `pi', keep(3) nogen

merge m:1 education using `theta', keep(3) nogen
merge m:1 education_d using `theta_d', keep(3) nogen


*Now I compute the summ
forvalues j=1/4 {
    generate temp`j'=index`j'*pi`j'*theta`j'
    generate tempd`j'=indexd`j'*pi`j'*theta_d`j'

    generate diff`j'=temp`j'-tempd`j'
}


generate weight1=obs*obs_d/(obs+obs_d)

generate weight2=people*people_d/(people+people_d)



egen sums=rowtotal(diff*)



*==========================================================================
*Initial graph of the sums versus the ratio
*==========================================================================
tw scatter y_var sums, ///
    xtitle("{&sum}(S{sub:eijt}-S{sub:e'ijt}){&pi}{sub:jt}") ///
    ytitle("ln(q{sub:ejt})-ln(q{sub:e'jt})") ///
    mcolor(ebblue%30)

*==========================================================================
*Graph of the sums versus the residuals
*==========================================================================
cap drop y_hat
cap drop residuals
cap drop ee_group_id

egen ee_group_id=group(education education_d year) if equation==3
regress y_var c.sums#i.occupation i.ee_group_id

*Getting parameter estimates
*=================================
regsave
split var, parse(".")
keep if var3=="sums"
replace var1="1121" if var1=="1121b"
destring var1, replace

rename coef coefficient
generate sigma_j=1/(1-coefficient)

generate bad_parameter=sigma_j>1

table bad_parameter


/*
*==========================================================================
*Graph of the sums versus the residuals
*==========================================================================

predict y_hat
predict residuals, resid


tw scatter residuals sums, msymbol(o) ///
     xtitle("{&sum}(S{sub:eijt}-S{sub:e'ijt}){&pi}{sub:jt}") ///
    ytitle("Residuals") ///
    mcolor(ebblue%30)


/*
*==========================================================================
*Flagging outliers
*==========================================================================
summarize residuals, d
generate outlier=!inrange(residuals,`r(p10)',`r(p90)')
generate big_occ=floor(occupation/100)

tw (kdensity sums if outlier, lcolor(black)) (kdensity sums if !outlier, lcolor(gold)),  legend(order(1 "Outlier" 2 "Not outlier"))

*==========================================================================
*Occupations
*==========================================================================

table big_occ outlier

generate outlier_occ=inlist(big_occ,21,34,52,53,54,82)




/*

egen ee_group_id=group(education education_d year) if equation==3


grscheme, ncolor(7) style(tableau)
eststo clear
eststo uw: regress y_var sums i.ee_group_id
eststo w: regress y_var sums i.ee_group_id  [aw=weight2]


esttab uw w, se mtitle(Unweighted weighted)


tw (scatter y_var sums, msymbol(o) mcolor(ebblue%30)) (lfit  y_var sums), ytitle("LHS") xtitle("RHS")

tw (scatter y_var sums [aw=weight2], msymbol(o) mcolor(ebblue%30)) (lfit  y_var sums), ytitle("LHS") xtitle("RHS")


*======================================================================================================================
*Graph of errors
*======================================================================================================================
cap drop y_hat
cap drop residuals

regress y_var c.sums#i.occupation i.ee_group_id
predict y_hat
predict residuals, resid


tw (scatter y_var y_hat, msymbol(o) mcolor(ebblue%30)) ///
    (lfit  y_var y_var), ytitle("Actual values") xtitle("Predicted values") ///
    legend( ring(0) pos(11) order(2 "45º degree line"))


*======================================================================================================================
*Flagging outliers
*======================================================================================================================
cap drop residp
fasterxtile  residp=residuals, nquantiles(100)  

generate outlier=!inrange(residp,6,94)

tab education education_d if outlier

tab occupation if outlier