
use $census2001, clear 

*Keep the sample to England and Wales

keep if inlist(country,1,3)

keep if inrange(age0,20, 60)

keep if hourspw>0

rename socmin occ2000 


*Drop people with unknown level of qualification

drop if qualvewn==6
generate education=.
replace education=1 if inlist(qualvewn,1,2,3)
replace education=2 if inlist(qualvewn,4)
replace education=3 if inlist(qualvewn,5)

save "data/additional_processing/clean_2001_census.dta", replace



