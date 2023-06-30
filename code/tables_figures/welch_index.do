
use "data/temporary/appended_LFS_occ_level", clear 

keep if year>=2001
drop if quarter==1&year==2001

rename $occupation occupation
rename edlevLFS education

gcollapse (sum) people, by(occupation education year)

egen educ_people=sum(people), by(education year)

generate emp_share=people/educ_people


egen occ_empl=sum(people), by(occupation year)
egen year_empl=sum(people), by(year)

generate occ_share=occ_empl/year_empl

keep emp_share occ_share occupation education year

reshape wide emp_share  occ_share , ///
	i(year occupation) j(education)

foreach variable of varlist emp_share0-occ_share4{
    replace `variable'=0 if missing(`variable')
}

order emp* occ_*, last

egen emp_share_all=rowmax(occ_share0-occ_share4)

drop occ_share0-occ_share4


*Now I compute the Welch Index 
foreach variable in emp_share {
	forvalues j=0/4 {
		g 		t`variable'W`j'=`variable'`j'-`variable'_all
		egen 	t`variable'Den`j'=sum((t`variable'W`j'^2)), by(year)
		replace t`variable'Den`j'=t`variable'Den`j'/`variable'_all
	}
}

*Computation of the indexes
foreach variable in emp_share  {
	forvalues i=0/4 {
		forvalues j=0/4 {
			g w`variable'`i'`j'=(t`variable'W`i'*t`variable'W`j'/`variable'_all)/ ///
						sqrt(t`variable'Den`i'*t`variable'Den`j')
		}
	}
	
	*Now I compute the actual indexes
	forvalues i=0/4 {
		forvalues j=0/4{
			egen w`variable'`i'`j'F=sum(w`variable'`i'`j'), by(year)
		}
	}
}


*Result table
local yearList 		1997 2001 2006 2012 2017
local nEduc			5
foreach variable in emp_share  {
	foreach year in `yearList' {
		matrix 	w`variable'`year'=J(`nEduc',`nEduc',.)
		forvalues i=0/4 {
			forvalues j=0/4{
				qui sum w`variable'`i'`j'F 
				qui matrix w`variable'`year'[`i'+1,`j'+1]= `r(mean)'
			}
		}
		di "Year=`year'"
		matrix list w`variable'`year'
	}
}

