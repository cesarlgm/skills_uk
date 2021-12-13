local  educationType 	`1'
local  occupation		`2'

if `educationType'==1 {
	local education		newEducation
}
else if `educationType'==2 {
	local education 	alternativeEducation
}
else if `educationType'==3 {
	local education 	fourEducation
}


use "tempFiles/borderJobClassificationLFS`educationType'", clear

g twoDigitOcc=`occupation'
tostring 	twoDigitOcc, replace
replace 	twoDigitOcc=substr(twoDigitOcc,1,2)
g			oneDigitOcc=substr(twoDigitOcc,1,1)
destring	twoDigitOcc, replace
destring	oneDigitOcc, replace

do "codeFiles/labelOccGroups"

*===============================================================================
*JOB COUNT GRAPHS
*===============================================================================
preserve
	*Let's first see what type of jobs start becoming border jobs
	keep year `occupation'  borderJob jobType *Digit*
	duplicates drop

	egen groupCount=count(`occupation'), by(oneDigitOcc year)
	egen borderGroup=sum(borderJob), by(oneDigitOcc year)
	g	 oneDigitShare=borderGroup/groupCount

	keep year oneDigit*
	duplicates drop

	kevinlineplot oneDigitShare year oneDigitOcc, ylab(Share of # jobs)
	graph export "output/jobCountShareOccGroup.pdf", replace
restore

foreach border in 12 23 13 {
	preserve
		*Let's first see what type of jobs start becoming border jobs
		keep year `occupation'  borderJob jobType *Digit*
		duplicates drop

		egen groupCount=count(`occupation'), by(oneDigitOcc year)
		egen borderGroup`border'=sum(borderJob*(jobType==`border')), by(oneDigitOcc year)
		g	 oneDigitShare=borderGroup`border'/groupCount

		keep year oneDigit*
		duplicates drop

		kevinlineplot oneDigitShare year oneDigitOcc, ylab(Share of # jobs) ///
			range(0 1) yscale(0(.2)1)
		graph export "output/jobCountShareOccGroup`border'.pdf", replace
	restore
}

*===============================================================================
*EMPLOYMENT SHARE GRAPHS
*===============================================================================
preserve
	g 	inBorder=	people*borderJob
	collapse (sum) people inBorder, by(year oneDigitOcc)
	g	emplShareBorder=inBorder/people

	kevinlineplot emplShareBorder year oneDigitOcc, ylab(Employment share in border)
	graph export "output/empShareOccGroup.pdf", replace
restore

foreach border in 12 23 13 {
	preserve
		g 	inBorder`border'=	people*borderJob*(jobType==`border')

		collapse (sum) people inBorder`border', by(year oneDigitOcc)
		g	emplShareBorder`border'=inBorder`border'/people
		
		kevinlineplot emplShareBorder`border' year oneDigitOcc, ///
			ylab(Employment share in border) range(0 1) yscale(0(.2)1)
		graph export "output/empShareOccGroup`border'.pdf", replace
	restore
}


*===============================================================================
*WITHIN JOB CLASSIFICATION DETAIL
*===============================================================================

*JOB COUNT GRAPS
keep if 	inlist(oneDigitOcc, 5,7,8,9)
levelsof 	oneDigitOcc
local 		occList `r(levels)'

*Let's first see what type of jobs start becoming border jobs
g 	inBorder=	people*borderJob
collapse (sum) people inBorder, by(year oneDigit twoDigitOcc)
g	emplShareBorder=inBorder/people

foreach occGroup in `occList' {
	preserve
		keep if oneDigitOcc==`occGroup'
		kevinlineplot emplShareBorder year twoDigitOcc, ylab(Share of employment)
		graph export "output/jobCountShareOccGroup`occGroup'.pdf", replace
	restore
}

*===============================================================================
*ZOOMING INTO GROUPS 8 AND 9
*===============================================================================

use "tempFiles/borderJobClassificationLFS`educationType'", clear

g twoDigitOcc=`occupation'
tostring 	twoDigitOcc, replace
g			threeDigitOcc=substr(twoDigitOcc,1,3)
replace 	twoDigitOcc=substr(twoDigitOcc,1,2)
g			oneDigitOcc=substr(twoDigitOcc,1,1)
destring 	threeDigitOcc, 	replace
destring	twoDigitOcc, 	replace
destring	oneDigitOcc, 	replace

do "codeFiles/labelOccGroups.do"

keep if inlist(oneDigitOcc, 8, 9)

g inBorder=			people*borderJob
collapse (sum) 		inBorder people, by(*Digit* year)
g shareInBorder=	inBorder/people

levelsof twoDigitOcc
local occList  `r(levels)'

di "`occList'"

foreach group in `occList' {
	preserve
		keep if twoDigitOcc==`group' 
		kevinlineplot shareInBorder year threeDigitOcc, ylab(Share of employment)
		graph export "output/zoomInOcc`group'.pdf", replace
	restore
}

*===============================================================================
*ZOOMING INTO GROUPS 8 AND 9
*===============================================================================

use "tempFiles/borderJobClassificationLFS`educationType'", clear

label define detailEduc ///
	1 "Below GCSE C" ///
	2 "GCSE C to A lev." ///
	3 "Bachelor +" 
label values `education' detailEduc

g twoDigitOcc=`occupation'
tostring 	twoDigitOcc, replace
g			threeDigitOcc=substr(twoDigitOcc,1,3)
replace 	twoDigitOcc=substr(twoDigitOcc,1,2)
g			oneDigitOcc=substr(twoDigitOcc,1,1)
destring 	threeDigitOcc, 	replace
destring	twoDigitOcc, 	replace
destring	oneDigitOcc, 	replace

do "codeFiles/labelOccGroups.do"

keep if inlist(threeDigitOcc, 813, 821, 822,922)

*List of occupations that "become" border jobs
keep if inlist(`occupation', 8131, 8134, 8136, 8139, 8211, 8213, 8214, 8221, ///
	8222, 8223, 8229, 9221, 9222, 9223, 9224, 9229)

levelsof `occupation'
local occupationList `r(levels)'

kevinlineplot educAggShare year `education' if `occupation'==8131, saving(population) ///
	range(0 .8) yscale(0(.2).8) title("Population shares") ylab("Employment share")
foreach occ in `occupationList' {
	kevinlineplot educOccShare year `education' if `occupation'==`occ', saving(`occ') ///
	ylab("") range(0 .8) yscale(0(.2).8) title(`occ')
}

grc1leg  "population" "8131" "8134" "8136" "8139"
graph export "output/occGraphs813.pdf", replace

grc1leg "population" "8211" "8213" "8214"
graph export "output/occGraphs821.pdf", replace

grc1leg  "population" "8221" "8222" "8223" "8229"
graph export "output/occGraphs822.pdf", replace

grc1leg  "population" "9221" "9222" "9223" "9224" "9229"
graph export "output/occGraphs922.pdf", replace
