*===============================================================================
*Classify jobs according to education
*===============================================================================
local occupation  		`2'
local educationType  	`1'


if `educationType'==1 {
	local education newEducation
	local nLevels=3
}
else if `educationType'==2 {
	local education alternativeEducation
	local nLevels=3
}
else if `educationType'==3 {
	local education fourEducation
	local nLevels=4
}

use "tempFiles/borderJobClassificationLFS`educationType'", clear

g twoDigitOcc=`occupation'
tostring 	twoDigitOcc, replace
replace 	twoDigitOcc=substr(twoDigitOcc,1,2)
g			oneDigitOcc=substr(twoDigitOcc,1,1)
destring	twoDigitOcc, replace
destring	oneDigitOcc, replace

do "codeFiles/labelOccGroups"

label define educationDet ///
	1 "Below GCSE C" ///
	2 "GCSE C to A lev." ///
	3 "Bachelor+"

label values `education' educationDet

g	jobTypeAlt=.
g populated1=inlist(jobType,1,12,13)*people
g populated2=inlist(jobType,2,12,23)*people
g populated3=inlist(jobType,3,13,23)*people


*Education employment share graph
preserve
	collapse (sum) people, by( year `education')
	egen 	totalEmployment=sum(people), by(year)
	g	 	empShare=people/totalEmployment
	
	kevinlineplot empShare year `education', ylab("Employment share") ///
		saving(educEmpShare) title("Overall employment") range(0 .6) ///
		yscale(0(.1).6)
restore


preserve
	*Excluding after
	collapse (sum) people, by(jobType year)
	egen 	totalEmployment=sum(people), by(year)
	g	 	empShare=people/totalEmployment
	keep if inlist(jobType, 1 , 2, 3)
	kevinlineplot empShare year jobType , ylab("Employment share") ///
		saving(educOccShare) title("Occupied jobs: excluding border") range(0 .6) ///
		yscale(0(.1).6)
restore


preserve
	*Excluding before
	keep if inlist(jobType, 1 , 2, 3)
	collapse (sum) people, by(jobType year)
	egen 	totalEmployment=sum(people), by(year)
	g	 	empShare=people/totalEmployment
	kevinlineplot empShare year jobType , ylab("Employment share") range(0 .6) ///
		yscale(0(.1).6)
	graph export "output/changeOccEmpSharesBefore.pdf", replace 
restore

*Including the border
preserve
	collapse (sum) populated* people, by(year)
	forvalues j=1/3 {
		g empShare`j'=populated`j'/people
	}
	
	reshape long empShare, i(year) j(`education')
	label values  `education' educationDet
	set graphics on 
	kevinlineplot empShare year `education' , ylab("Employment share") ///
		title("Occupied jobs: including border") saving(educOccShareEx) range(0 .6) ///
		yscale(0(.1).6)
restore

grc1leg "educEmpShare" "educOccShare" "educOccShareEx"
graph export "output/educationEmpShares.pdf", replace

rm "educEmpShare.gph" 
rm "educOccShare.gph" 
rm "educOccShareEx.gph"
