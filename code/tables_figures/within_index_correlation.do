*========================================================
*GETTING CORRELATIONS WITHIN INDEXES
*========================================================

global education educ_3_low

use "data/temporary/filtered_dems_SES", clear
drop if missing(gwtall)

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

rename $education education
rename bsoc00Agg occupation


do "code/process_SES/compute_skill_indexes.do"

log using "results/tables/within_index_corr.txt", text replace
foreach index in $index_list {
    pwcorr ${`index'}
}
log close


foreach variable in $routine {
    replace `variable'=-`variable'
}

pwcorr $manual $social $routine $abstract


