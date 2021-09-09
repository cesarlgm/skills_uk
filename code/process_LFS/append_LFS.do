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
