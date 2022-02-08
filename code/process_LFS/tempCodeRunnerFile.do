
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


save "data/temporary/LFS_industry_occ_file", replace

