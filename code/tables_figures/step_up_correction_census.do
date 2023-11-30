use "data/additional_processing/appended_census_occ_ind", clear

        
xi i.education, noomit

drop if year==2001

rename occ2010 occupation

levelsof occupation
local occupation_list `r(levels)'

tempfile occupations
save `occupations'

eststo clear
foreach occu in `occupation_list' {
    foreach educ in 1 2 3 {
        qui regress _Ieducation_`educ'  i.year [weight=weight] if occupation==`occu'
        preserve
        regsave
        qui split var, parse(. #)
        qui keep if var1=="2021" & var2=="year"

        qui generate occupation=`occu'
        qui generate t_stat=coef/stderr
        qui generate p_value`educ'=1-normal(t_stat)

        rename coef coef`educ'
        rename t_stat t_stat`educ'

        keep coef t_stat* p_value* occupation
        
        qui save "data/additional_processing/share_changes/t_`occu'_`educ'_census", replace
        restore
    }
}


clear
foreach educ in 1 2 3 {
    use  "data/additional_processing/share_changes/t_111_`educ'_census", clear
    foreach occu in `occupation_list' {
        append using "data/additional_processing/share_changes/t_`occu'_`educ'_census"
    }

    duplicates drop 
    save "data/additional_processing/share_changes/t_`educ'_census", replace
}

use  "data/additional_processing/share_changes/t_1_census", clear 
merge 1:1 occupation  using   "data/additional_processing/share_changes/t_2_census", nogen
merge 1:1 occupation  using   "data/additional_processing/share_changes/t_3_census", nogen   


local alpha=.1
forvalues educ=1/3 {
    gsort p_value`educ'
    summ p_value`educ'
    generate threshold`educ'=`alpha'*_n/`r(N)'
    generate reject`educ'=p_value`educ'<threshold`educ'

    generate simple_reject`educ'=p_value`educ'<=`alpha'
}


tempfile t_tests
save `t_tests'

use `occupations', clear


gcollapse (mean) _I* [weight=weight], by(occupation year)

merge m:1  occupation using `t_tests', nogen

rename _Ieducation_1 empshare_1 
rename _Ieducation_2 empshare_2 
rename _Ieducation_3 empshare_3

save "data/additional_processing/t_tests_census", replace