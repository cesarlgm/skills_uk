


use "data/temporary/filtered_dems_SES", clear

replace cplanoth=6-cplanoth

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

cap log close
log using "results/log_files/n_observations_year.txt", replace
table year
log close
