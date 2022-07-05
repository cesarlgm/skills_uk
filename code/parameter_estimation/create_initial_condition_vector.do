
use "data/additional_processing/gmm_example_dataset", clear

preserve
keep if equation==1
keep occupation occ_id 
duplicates drop
tempfile occ_id
save `occ_id'
restore

*Equation 1
regress y_var e1s* if equation==1, nocons

preserve

regsave

    split var, parse("_")

    rename var2 occ_id
    rename var3 year_id
    rename var4 skill

    foreach variable in occ_id year_id skill {
        destring `variable', replace
    }

    keep coef occ_id year_id skill

    sort  occ_id year_id skill

    generate equation=1

    merge m:1 occ_id using `occ_id', keep(3) nogen

    save "data/temporary/initial_pi", replace

    reshape wide coef, i(occ_id year_id) j(skill)


    tempfile pi_file
    save `pi_file'
restore


regress y_var ts_* if equation==2, nocon

regsave

{
    split var, parse("_")
    generate education=substr(var2,-1,.)

    generate skill=.
    replace skill=1 if regexm(var2,"manual")==1
    replace skill=2 if regexm(var2,"social")==1
    replace skill=3 if regexm(var2,"routine")==1
    replace skill=4 if regexm(var2,"abstract")==1

    keep skill education coef 

    destring education, replace

    generate equation=2
    save "data/temporary/initial_theta", replace

    preserve 
    rename coef theta_num


    reshape wide theta_num, i(education) j(skill)
    tempfile theta_num
    save `theta_num'

    restore

    rename education education_d
    rename coef theta_den

    reshape wide theta_den, i(education_d) j(skill)
    tempfile theta_den
    save `theta_den'
}


use "data/additional_processing/gmm_example_dataset", clear

keep if equation==3

merge m:1 occ_id year_id using  `pi_file', keep(3) nogen

merge m:1 education using  `theta_num', keep(3) nogen

merge m:1 education_d  using  `theta_den', keep(3) nogen


*I compute the skill aggregate
forvalues j=1/3 {
    generate temp`j'=theta_num`j'*ezn_index`j'-theta_den`j'*ezd_indexd`j'
}
egen skill_sum=rowtotal(temp*)

regress y_var i.occupation#c.skill_sum x*, nocons

regsave 

split var, parse("." "_")

replace var1=regexr(var1,"b","")

cap drop parameter
generate parameter="sigma" if var3=="skill"
replace parameter="x" if var3==""

destring var1, replace

replace coef=1/(1-coef) if parameter=="sigma"


generate parameter_id=var1 if var1!="x"
replace parameter_id=var2 if var1=="x"

keep coef parameter parameter_id

generate equation=3

save "data/temporary/sigma_x", replace

clear

append using "data/temporary/initial_theta"
append using  "data/temporary/initial_pi"
append using "data/temporary/sigma_x"

destring parameter_id, replace

replace occupation=parameter_id if equation==3&parameter=="sigma"

generate temp=coef/(coef-1) if parameter=="sigma"
egen  beta=mean(temp), by(occupation)

generate dln_a=coef/beta if equation==1

generate parameter_type=1 if equation==2
replace parameter_type=2 if equation==1
replace parameter_type=3 if equation==3&parameter=="sigma"
replace parameter_type=4 if equation==3&parameter=="x"


generate first_order=.
generate second_order=.
generate third_order=.


*Theta order is ok
replace first_order=education if parameter_type==1
replace second_order=skill if parameter_type==1


*dlna is ok
replace first_order=skill if parameter_type==2
replace second_order=occ_id if parameter_type==2
replace third_order=year_id if parameter_type==2

*sigma order is just jobs
replace first_order=occupation if parameter_type==3
replace first_order=parameter_id if parameter_type==4

generate estimate=coef if parameter_type!=2
replace  estimate=dln_a if parameter_type==2

sort parameter_type first_order second_order

generate parameter_no=_n


keep estimate parameter_type parameter_no

export delimited using  "data/additional_processing/initial_estimates.csv", replace

