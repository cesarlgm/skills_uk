*===============================================================================
*This creates the welch index correlation tables LFS
*===============================================================================

local education 	`1'
local occupation 	`2'

use "./tempFiles/educEmploymentSharesLFS", clear

drop educPeople educObs age

egen totalPeople=sum(people), by(year)
egen totalObs=sum(observations), by(year)

egen occPeople=		sum(people), by(year `occupation')
egen occObs=		sum(observations), by(year `occupation')

g	 occPplEmpShare=occPeople/totalPeople
g	 occObsEmpShare=occObs/totalObs

drop totalPeople totalObs occPeople occObs people observations

reshape wide educEmpShare  educObsShare occPplEmpShare occObsEmpShare, ///
	i(year `occupation') j(`education')

order educEmp* educObs* occPpl* occObs*, after(`occupation')
drop occPplEmpShare1-occPplEmpShare4 occObsEmpShare1-occObsEmpShare4

rename occPplEmpShare0 occPplEmpShare
rename occObsEmpShare0 occObsEmpShare

label var educEmpShare0 "No qualification"
label var educEmpShare1 "GCSE D-G levels"
label var educEmpShare2 "GCSE A-C levels"
label var educEmpShare3 "GCE A* / trade apprenticeship"
label var educEmpShare4 "Bachelor's or more"

label var educObsShare0 "No qualification"
label var educObsShare1 "GCSE D-G levels"
label var educObsShare2 "GCSE A-C levels"
label var educObsShare3 "GCE A* / trade apprenticeship"
label var educObsShare4 "Bachelor's or more"

label var occPplEmpShare "Population occ employment share"
label var occObsEmpShare "Population occ obs employment share"

rename occPplEmpShare educEmpShareAll
rename occObsEmpShare educObsShareAll

*Now I compute the Welch Index 
foreach variable in educEmpShare educObsShare {
	forvalues j=0/4 {
		g 		t`variable'W`j'=`variable'`j'-`variable'All
		egen 	t`variable'Den`j'=sum((t`variable'W`j'^2)), by(year)
		replace t`variable'Den`j'=t`variable'Den`j'/`variable'All
	}
}

*Computation of the indexes
foreach variable in educEmpShare educObsShare {
	forvalues i=0/4 {
		forvalues j=0/4 {
			g w`variable'`i'`j'=(t`variable'W`i'*t`variable'W`j'/`variable'All)/ ///
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
foreach variable in educEmpShare educObsShare {
	foreach year in `yearList' {
		matrix 	w`variable'`year'=J(`nEduc',`nEduc',.)
		forvalues i=0/4 {
			forvalues j=0/4{
				qui sum w`variable'`i'`j'F if year==`year'
				qui matrix w`variable'`year'[`i'+1,`j'+1]= `r(mean)'
			}
		}
		di "Year=`year'"
		matrix list w`variable'`year'
	}
}

