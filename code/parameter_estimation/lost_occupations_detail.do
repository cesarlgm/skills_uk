
use  "data/additional_processing/gmm_skills_dataset", clear

keep if equation==1

generate mis_y_var=missing(y_var)

cap drop temp
gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
egen n_educ=max(temp), by(occupation year)

preserve
    keep if n_educ==3
    keep occupation
    unique occupation 
    generate in_panel=1
    duplicates drop
    tempfile kept_occ
    save `kept_occ'
restore

merge m:1 occupation using `kept_occ', nogen keep(1)
