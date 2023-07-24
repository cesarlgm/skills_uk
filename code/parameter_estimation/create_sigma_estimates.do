*==========================================================================================
*CREATE SIGMAS ESTIMATES
*==========================================================================================
{
    import excel "data\output\theta_estimates_twoeq.xlsx", sheet("Sheet1") firstrow clear

    drop theta_code se 
    rename estimate theta
    reshape wide theta, i(education) j(skill)


    tempfile theta
    save `theta'

    import excel "data\output\theta_estimates_twoeq.xlsx", sheet("Sheet1") firstrow clear

    drop theta_code se 
    rename estimate theta_d
    reshape wide theta, i(education) j(skill)

    rename education education_d
    tempfile theta_d
    save `theta_d'


    import excel "data\output\pi_estimates_twoeq.xlsx", sheet("Sheet1") firstrow clear

    drop code se t
    rename estimate pi
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
    regress y_var c.sums#i.occupation ibn.ee_group_id, nocons

    preserve 
    *Getting parameter estimates
    *=================================
    regsave

    split var, parse(".")
    keep if var3=="sums"
    replace var1="1121" if var1=="1121b"
    destring var1, replace

    rename var1 occupation 

    rename coef beta
    generate sigma=1/(1-beta)

    generate bad_parameter=sigma>1

    table bad_parameter

    keep occupation beta sigma bad_parameter stderr

    order occupation sigma stderr bad_parameter

    rename stderr beta_se

    generate sigma_se=abs((1/(1-beta))*beta_se)

    drop beta beta_se

    generate sigma_t_one=(sigma-1)/sigma_se
    generate significant_one=sigma_t_one>1.644854

    generate sigma_t_zero=sigma/sigma_se
    generate significant_zero=abs(sigma_t_zero)>1.644854

    tab significant_zero

    save "data/output/sigma_twoeq", replace
    restore
}

preserve
*Create sigma estimates with the same instruments
{
    use "data/additional_processing/gmm_example_dataset", clear
    keep if equation==3

    keep occupation education education_d year e3jy_* e3jep_*

    tempfile same_inst
    save `same_inst'
}
restore

keep occupation education education_d year y_var sums ee_group_id
merge 1:1 occupation education education_d year using `same_inst', nogen keep(3)


ivreg2 y_var (c.sums#ibn.occupation=e3jy_* e3jep_*) ibn.ee_group_id, nocons

regsave
split var, parse(".")
keep if var3=="sums"
replace var1="1121" if var1=="1121b"
destring var1, replace

rename coef beta
generate sigma=1/(1-beta)

summ sigma

rename stderr beta_se

generate sigma_se=abs((1/(1-beta))*beta_se)


drop beta beta_se

generate sigma_t_one=(sigma-1)/sigma_se
generate significant_one=sigma_t_one>1.644854

generate sigma_t_zero=sigma/sigma_se
generate significant_zero=abs(sigma_t_zero)>1.644854


summ sigma, d 




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