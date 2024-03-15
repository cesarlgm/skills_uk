*===============================================================================
*APPEND LFS DATABASES
*================================================================================
clear

forvalues year=2001/2020 {
	forvalues quarter=1/4 {
		if !((`year'==2001&`quarter'==1)|(`quarter'==1&`year'==2004)){
			append using "data/temporary/LFS`year'q`quarter'_wage_collapsed"
		}
	}
}

do "code/aggregate_SOC2000.do"

drop if bsoc00Agg==-9

keep if inrange(year,2001,2020)
 

keep if inrange(year,2001,2003)|inrange(year,2005,2007)|inrange(year,2011,2013)|inrange(year,2015,2017)

replace year=2001 if inrange(year,2001,2003)
replace year=2006 if inrange(year,2005,2007)
replace year=2012 if inrange(year,2011,2013)
replace year=2017 if inrange(year,2015,2017)

tab year

do "code/process_LFS/create_education_variables.do"

preserve 
gcollapse (mean) $continuous_list [aw=people], by(bsoc00Agg year  $education)
tempfile wages
save `wages'
restore 

gcollapse (sum) people observations , by(bsoc00Agg year  $education)

merge 1:1 bsoc00Agg year  $education using `wages', nogen 

drop if missing(bsoc00Agg)

save "data/temporary/LFS_wage_occ_file", replace

