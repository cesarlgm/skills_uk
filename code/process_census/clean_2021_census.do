
use $census2021, clear 


rename resident_age_74m age

keep if inrange(age,20, 64)

keep if hours>0

rename occupation_105a occ2021  

drop if highest_qualification==-8
drop if highest_qualification==6

generate education=.
replace education=1 if inlist(highest_qualification,0,1,2)
replace education=2 if inlist(highest_qualification,3,4)
replace education=3 if inlist(highest_qualification,5)

tab education, mis 


save "data/additional_processing/clean_2021_census.dta", replace

