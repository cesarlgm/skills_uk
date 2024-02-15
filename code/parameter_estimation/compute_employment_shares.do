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


drop year 
rename n_year year

merge m:1 education using `theta', keep(3) nogen
merge m:1 education_d using `theta_d', keep(3) nogen
merge m:1 occupation year using `dlna', keep(3) nogen 

forvalues skill=2/4 {
    generate temp`skill'=(theta`skill'*index`skill'-theta_d`skill'*indexd`skill')*dlna`skill'
}

egen rhs=rowtotal(temp*)

replace rhs=. if missing(temp4)

egen pair_d=group(education education_d year)

egen temp=mean(dlnq), by(pair_d)
generate net_dlnq=dlnq-temp

grscheme, palette(tableau) ncolor(7)
binscatter dlnq rhs, msymbol(oh) xtitle("Sum of skills*dlna") ytitle("")  ytitle("Change in employment")


binscatter net_dlnq rhs, msymbol(oh) xtitle("Sum of skills*dlna")  ytitle("Change in employment")

tw (scatter net_dlnq rhs) (lfit net_dlnq rhs), xtitle("Sum of skills*dlna")  ytitle("Change in employment") legend(off)

