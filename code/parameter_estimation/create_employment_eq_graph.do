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

tw scatter y_var sums

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

regress y_var c.sums#i.occupation i.ee_group_id
predict y_hat

tw (scatter y_var y_hat, msymbol(o) mcolor(ebblue%30)) ///
    (lfit  y_var y_var), ytitle("Actual values") xtitle("Predicted values") ///
    legend( ring(0) pos(11) order(2 "45º degree line"))

