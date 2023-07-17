*Compare two and three equation sigmas
use "data/additional_processing/gmm_skills_dataset", clear
decode occupation, g(occ_name)
keep occupation occ_name
duplicates drop

tempfile occ_names
save `occ_names'


*First, I import the three equation sigmas
import excel "data\output\sigma_estimates.xlsx", sheet("Sheet1") firstrow clear
rename estimate three_eq
tempfile three_eq
save `three_eq'

use "data/output/sigma_twoeq", clear 

rename sigma two_eq

merge 1:1 occupation using `three_eq', keep(1 3)

table _merge bad_parameter

cap drop _merge
merge 1:1 occupation using `occ_names', keep(1 3) nogen

labmask occupation, values(occ_name)

drop occ_name

tab occupation if bad_parameter 

