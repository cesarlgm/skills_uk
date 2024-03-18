
*This file estimates equation 23
use "data/additional_processing/gmm_skills_dataset`1'", clear

rename (manual social routine abstract_a2) (index#), addnumber

keep if skill==1 & equation==1

egen time=group(year)

egen id=group(occupation education)

xtset id time

keep occupation year education index* id time *obs* 


forvalues skill=1/4 {
    generate a_index`skill'=0.5*(index`skill'+l.index`skill')
    generate n_index`skill'=l.index`skill'
    drop index`skill'
    rename n_index`skill' index`skill'
}

 generate a_obs=l.obs+obs
generate n_obs=l.obs 
drop obs
rename n_obs obs


keep if year>2001

drop id time

tempfile skills
save `skills'


*Step 1: I import all the  estimates from the model
import excel "data\output\theta_estimates_eq6.xlsx", sheet("Sheet1") firstrow clear

drop theta_code
drop se 
rename estimate theta
reshape wide theta, i(education) j(skill)

tempfile theta
save `theta'

rename education education_d
rename theta* theta_d*
tempfile theta_d
save `theta_d'

import excel "data\output\dlna_estimates_eq6.xlsx", sheet("Sheet1") firstrow clear

egen period=group(year)
egen id=group(occupation skill)

xtset id period 

generate dlna=d.estimate

drop estimate id period
drop se t code 
reshape wide dlna, i(occupation year) j(skill)

tempfile dlna
save `dlna'




use "data/temporary/LFS_wage_occ_file", clear

cap drop people
cap drop obs

rename bsoc00Agg occupation 
rename educ_3_low education

egen time=group(year)

egen id=group(occupation education)

xtset id time

generate d_al_wkpay=d.al_wkpay
generate d_al_hourpay=d.al_hourpay


drop if missing(d_al_hourpay)


merge m:1 education using `theta', keep(3) nogen
merge m:1 occupation year using `dlna', keep(3) nogen 
merge 1:1 occupation education year using `skills', keep(3) nogen

drop if missing(dlna2)

forvalues skill=2/4{
    generate temp`skill'=index`skill'*dlna`skill'*theta`skill'
    generate atemp`skill'=a_index`skill'*dlna`skill'*theta`skill'
    
}

egen w_skill=rowtotal(temp2 temp3 temp4)
egen aw_skill=rowtotal(atemp2 atemp3 atemp4)


egen rid=group(occupation year)

eststo clear

qui {
eststo est1: reghdfe d_al_hourpay w_skill,  absorb(rid) vce(r)
eststo est2: fgls_skills d_al_hourpay w_skill,  absorb(rid) 
eststo est3: reghdfe d_al_hourpay w_skill [aw=obs],  absorb(rid) vce(r)
eststo est4: fgls_skills d_al_hourpay w_skill [aw=obs],  absorb(rid) 
}

esttab est*, se

eststo clear

qui {
eststo est5: reghdfe d_al_wkpay w_skill,  absorb(rid) vce(r)
eststo est6: fgls_skills d_al_wkpay w_skill,  absorb(rid) 
eststo est7: reghdfe d_al_wkpay w_skill [aw=obs],  absorb(rid) vce(r)
eststo est8: fgls_skills d_al_wkpay w_skill [aw=obs],  absorb(rid) 
}

esttab est*, se 


*eststo est2: fgls_skills d_al_wkpay w_skill,  absorb(rid) 


/*
eststo: reghdfe d_al_hourpay w_skill [aw=obs], absorb(rid) vce(cl occupation)
eststo: reghdfe d_al_hourpay aw_skill, absorb(rid) vce(cl occupation)
eststo: reghdfe d_al_hourpay aw_skill [aw=a_obs], absorb(rid) vce(cl occupation)

esttab *, se  star(* .1 ** .05 *** .01)

eststo clear
eststo: reghdfe d_al_wkpay w_skill, absorb(rid) vce(cl occupation)
eststo: reghdfe d_al_wkpay w_skill [aw=obs], absorb(rid) vce(cl occupation)
eststo: reghdfe d_al_wkpay aw_skill, absorb(rid) vce(cl occupation)
eststo: reghdfe d_al_wkpay aw_skill [aw=a_obs], absorb(rid) vce(cl occupation)

esttab *, se  star(* .1 ** .05 *** .01)








