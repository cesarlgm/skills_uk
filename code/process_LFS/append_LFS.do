*===============================================================================
*APPEND LFS DATABASES
*================================================================================
clear
local education 		`1'

forvalues year=1997/2017 {
	forvalues quarter=1/4 {
		if !((`year'==2001&`quarter'==1)|(`quarter'==1&`year'==2004)){
			append using "data/temporary/LFS`year'q`quarter'_collapsed"
		}
	}
}

do "code/aggregate_SOC2000.do"

save "data/temporary/appended_LFS_occ_level", replace

*Here, if I want it I aggregate the SOC2000 further
*=======================================================
local occupation bsoc00Agg

local continuousList grossPay grossWkPayMain hourpay l_hourpay age

cap drop observations
rename people weight

generate people=1

collapse (mean)  `continuousList' (sum) people [pw=weight], ///
	by(`education' `occupation' year) 
	
*Note Apr 6: the averages here look fine.
save "data/temporary/LFS_agg_database", replace


clear
*Here, I aggregate files for the employment share regressions
*=======================================================
forvalues year=2001/2017 {
	forvalues quarter=1/4 {
		if !((`year'==2001&`quarter'==1)|(`quarter'==1&`year'==2004)){
			append using "data/temporary/LFS`year'q`quarter'_industry_cw"
		}
	}
}

do "code/aggregate_SOC2000.do"

keep if inrange(year,2001,2003)|inrange(year,2005,2007)|inrange(year,2011,2013)|inrange(year,2015,2017)

replace year=2001 if inrange(year,2001,2003)
replace year=2006 if inrange(year,2005,2007)
replace year=2012 if inrange(year,2011,2013)
replace year=2017 if inrange(year,2015,2017)



do "code/process_LFS/create_education_variables.do"


gcollapse (sum) people observations, by(bsoc00Agg industry_cw year educ_3_low)

drop if industry_cw<0

save "data/temporary/LFS_industry_occ_file", replace

