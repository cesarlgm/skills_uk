
use $census2011, clear 

keep if inrange(age,20, 64)

keep if hours>0

rename socmin occ2010 

drop if hlqupuk11==16
generate education=.
replace education=1 if inlist(hlqupuk11,10,11,12)
replace education=2 if inlist(hlqupuk11,13,14)
replace education=3 if inlist(hlqupuk11,15)

tab education

save "data/additional_processing/clean_2011_census.dta", replace





