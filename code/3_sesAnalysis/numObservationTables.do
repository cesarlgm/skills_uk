*==============================================================================
*Outputs table with the number of observations per education level
*===============================================================================
*===============================================================================
local occupation		`1'
local educationType		`2'
local aggregateSOC		`3'
local regressionType	`4'
*===============================================================================

local obsMin			3
local errors			vce(r)
local rankCap			5
local space 			\hspace{3mm}

use "./output/skillSESDatabase", clear
drop if missing(gwtall)

if `aggregateSOC'==1 {
	local occupation bsoc00Agg
}


if `educationType'==1{
	local education newEducation
	
}
else if `educationType'==2{
	local education alternativeEducation
	local educMax=3
	label define skillLabel 1 "\hspace{3mm}Below GCSE C" 2 "\hspace{3mm}GCSE C-A levels" ///
	3 "\hspace{3mm}Bachelor+"
	local baseLow	"Base level: Below GCSE C"
	local baseMid	"Base level: GCSE C-A levels"
}
else if `educationType'==3 {
	local education fourEducation
}



ds *Factor *Ort *Index
foreach variable in `r(varlist)' {
	xtile temp=`variable', nq(100)
	replace `variable'=temp
	drop temp
}

g twoDigitOcc=`occupation'
tostring 	twoDigitOcc, replace
g			threeDigitOcc=substr(twoDigitOcc,1,3)
replace 	twoDigitOcc=substr(twoDigitOcc,1,2)
g			oneDigitOcc=substr(twoDigitOcc,1,1)
destring 	threeDigitOcc, 	replace
destring	twoDigitOcc, 	replace
destring	oneDigitOcc, 	replace

do "codeFiles/labelOccGroups.do"

g	graphLow=inlist(jobType, 1,2,12)&`education'==1
g	graphMid=inlist(jobType, 1,2,12)&`education'==2

g	graphMidH=inlist(jobType, 2,3,23)&`education'==2
g	graphHigh=inlist(jobType, 2,3,23)&`education'==3

g 	borderGraph12=inlist(jobType, 12)&inlist(`education',1,2)
g 	borderGraph23=inlist(jobType, 23)&inlist(`education',2,3)


*possible skill lists I use
local averageList 		analyticalIndex 	manualIndex 	RIndex
local restrictedList	analyticalFactor 	manualFactor 	RFactor
local orthogonalList	analyticalOrt 		manualOrt 		ROrt


levelsof jobType
local typeList `r(levels)'

*Creating regressions
foreach skill in `averageList' `restrictedList' `orthogonalList' {
	foreach type in `typeList' {
		cap qui eststo `skill'`type': reghdfe `skill' i.`education' ///
			if jobType==`type', absorb(i.`occupation' i.year ) vce(r)
	}
}

preserve
*Here I create the table containing the number of observations per education level
collapse (sum) _est*analyticalIndex* , by(`education')

*I reshape the dataset to create the desired table
g 		dum=_n
reshape long _est_analyticalIndex, i(dum) j(jobType)
rename 	_est_analyticalIndex observations
drop 	dum

reshape wide observations, i(jobType) j(`education')

label define jobType 	1 "`space'Below GCSE C" ///
						2 "`space'GCSE C to A lev." ///
						3 "`space'Bachelor +" ///
						12 "`space'Below GCSE C / GCSE C to A lev."  ///
						23 "`space'GCSE C to A lev. / Bachelor + \vspace{3mm}" 
						
label values jobType jobType
label var jobType "Type of job"


*Dummy code to extract the number of observations
*-------------------------------------------------
expand 2
levelsof jobType
forvalues educ=1/`educMax' {
	eststo obs`educ': reg observations`educ' ibn.jobType, nocons
}

*===============================================================================
*Outputting totals part of the table
*===============================================================================

local tableName "output/skillRegressionsTable`educationType'Observations.tex"
local colTitles `""GCSE C-" "GCSE C-A lev.""Bachelor+""'
local tableTitle	"Observations in regressions by job type and education level"
local tableOptions  label append booktabs f collabels(none) ///
	nomtitles plain b(%9.0fc) not noobs par star 

textablehead  using `tableName', ncols(`educMax') coltitles(`colTitles') ///
	key(tab:nobs) drop sup("Education level") col(r) f("Job Type") ///
	title(`tableTitle')

writeln `tableName' "\textit{A. Total observations} \\"
esttab obs* using `tableName', `tableOptions'

restore


*===============================================================================
*Outputting mean observations of the table
*===============================================================================
preserve

levelsof jobType
g inRegression=.
foreach type in `r(levels)' {
	if "`type'"!="13" {
		replace inRegression=jobType if _est_analyticalIndex`type'==1
	}
}
drop _est*
keep if !missing(inRegression)

collapse (count) observations=year, by(`education' `occupation' inRegression)
collapse (mean) observations, by(`education' inRegression)
rename inRegression jobType

reshape wide observations, i(jobType) j(`education')

label define jobType 	1 "`space'Below GCSE C" ///
						2 "`space'GCSE C to A lev." ///
						3 "`space'Bachelor +" ///
						12 "`space'Below GCSE C / GCSE C to A lev."  ///
						23 "`space'GCSE C to A lev. / Bachelor + \vspace{3mm}" 
						
label values jobType jobType
label var jobType "Type of job"

*Dummy code to extract the number of observations
*-------------------------------------------------
eststo clear
expand 2
levelsof jobType
forvalues educ=1/`educMax' {
	eststo obs`educ': reg observations`educ' ibn.jobType, nocons
}

writeln `tableName' "\textit{B. Mean observations per occupation} \\"

local tableOptions  label append booktabs f collabels(none) ///
	nomtitles plain b(%9.2fc) not noobs par star 

esttab obs* using `tableName', `tableOptions'

restore
*===============================================================================
*Outputting diean observations of the table
*===============================================================================
levelsof jobType
g inRegression=.
foreach type in `r(levels)' {
	if "`type'"!="13" {
		replace inRegression=jobType if _est_analyticalIndex`type'==1
	}
}
drop _est*
keep if !missing(inRegression)

collapse (count) observations=year, by(`education' `occupation' inRegression)

collapse (median) observations, by(`education' inRegression)
rename inRegression jobType

reshape wide observations, i(jobType) j(`education')

label define jobType 	1 "`space'Below GCSE C" ///
						2 "`space'GCSE C to A lev." ///
						3 "`space'Bachelor +" ///
						12 "`space'Below GCSE C / GCSE C to A lev."  ///
						23 "`space'GCSE C to A lev. / Bachelor + \vspace{3mm}" 
						
label values jobType jobType
label var jobType "Type of job"

*Dummy code to extract the number of observations
*-------------------------------------------------
eststo clear
expand 2
levelsof jobType
forvalues educ=1/`educMax' {
	eststo obs`educ': reg observations`educ' ibn.jobType, nocons
}

writeln `tableName' "\textit{C. Median observations per occupation} \\"

local tableOptions  label append booktabs f collabels(none) ///
	nomtitles plain b(%9.0fc) not noobs par star 

esttab obs* using `tableName', `tableOptions'


*===============================================================================
*Closing the table
*===============================================================================
textablefoot using `tableName'
