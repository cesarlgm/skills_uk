*This file estimates equation 23

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


use "data/additional_processing/gmm_employment_dataset`1'", clear



egen period=group(year)
egen id=group(occupation education education_d)

xtset id period 

generate dlnq=f.y_var-y_var
generate n_year=f.year


egen occ_obs=sum(obs), by(year occupation)

generate adj_obs=obs+f.obs+obs_d+f.obs_d

forvalues skill=1/4 {
    generate avg_index`skill'=0.5*(index`skill'+f.index`skill')
    generate avg_indexd`skill'=0.5*(indexd`skill'+f.indexd`skill')
}



drop year 
rename n_year year

merge m:1 education using `theta', keep(3) nogen
merge m:1 education_d using `theta_d', keep(3) nogen
merge m:1 occupation year using `dlna', keep(3) nogen 

forvalues skill=2/4 {
    generate temp`skill'=(theta`skill'*index`skill'-theta_d`skill'*index`skill')*dlna`skill'
}

egen rhs=rowtotal(temp*)

replace rhs=. if missing(temp4)

egen pair_d=group(education education_d year)

egen temp=mean(dlnq), by(pair_d)
generate net_dlnq=dlnq-temp

gstats winsor net_dlnq, cut(5 95) replace
gstats winsor rhs, cut(5 95) replace

cap drop max_weight
cap drop max_weight_lfs
egen max_weight=rowtotal(sobs dobs)
egen max_weight_lfs=rowtotal(obs obs_d)

eststo est1: regress net_dlnq rhs, vce(r) 
eststo est2: regress net_dlnq rhs [aw=adj_obs], vce(r)
eststo est3:  regress net_dlnq rhs [aw=obs], vce(r)

esttab est1 est2 est3, se


/*
grscheme, palette(tableau) ncolor(7)
binscatter dlnq rhs, msymbol(oh) xtitle("Sum of skills*dlna") ytitle("")  ytitle("Change in employment")

binscatter net_dlnq rhs, msymbol(oh) xtitle("Sum of skills*dlna")  ytitle("Change in employment")

tw (scatter net_dlnq rhs) (lfit net_dlnq rhs), xtitle("Sum of skills*dlna")  ytitle("Change in employment") legend(off)

