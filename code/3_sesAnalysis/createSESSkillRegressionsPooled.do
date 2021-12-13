*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	regressions tables focussing on different measures of routine 
				pc use.
	
	output: 

*/
*===============================================================================
*===============================================================================
local occupation		`1'
local educationType		`2'
local aggregateSOC		`3'
local regressionType	`4'
*===============================================================================
local do_location 		"3\_sesAnalysis/createSESSkillRegressionsPooled.do"

local obsMin			3
local errors			vce(r)
local rankCap			5

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
	label define skillLabel 1 "Below GCSE C" 2 "GCSE C-A levels" ///
	3 "\midrule Bachelor+"
	local baseLow	"Base level: Below GCSE C"
	local baseMid	"Base level: GCSE C-A levels"
}
else if `educationType'==3 {
	local education fourEducation
}




ds *Factor *Ort 
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
local averageList 		analyticalIndex 	manualIndex 	 	bmuseIndex
local averageListSd 	analyticalIndex_sd 	manualIndex_sd 	 	bmuseIndex_sd
local restrictedList	analyticalFactor 	manualFactor 		bmuseFactor
local orthogonalList	analyticalOrt 		manualOrt 			bmuseOrt


*Creating regressions
foreach skill in `averageList' `restrictedList' `orthogonalList' `averageListSd' {
	*First I compute the standard deviation
	preserve
		collapse (mean) `skill' (count) observations=year, by(`occupation')
		summ `skill' [aw=observations]		
		local occ_sd=`r(sd)'
	restore
	
	cap qui eststo `skill': areg `skill' i.`education'  i.year, ///
		absorb(`occupation') vce(r)
		
	*Standardizing the coefficient

	local standard2=_b[2.`education']/ `occ_sd'
	local standard3=_b[3.`education']/ `occ_sd'
	cap estadd scalar occ_sd= `occ_sd'
	cap estadd scalar standard2= `standard2'
	cap estadd scalar standard3= `standard3'
	cap qui eststo `skill'	
}

*Creation of the tables
local coltitles=`""Analytical""Manual""Routine""'

local tableTitle "Relative skill use across education groups (simple average indexes)"
local tableNote "all skill indexes range between 0 and 1. Regressions use individual-level data. Robust standard errors in parenthesis. Coefficents represent the difference relative the lower education level. I use dummy of basic to moderate PC use complexity as measure of routineness. I pool data from all years. Regressions include occupation fixed-effects. Effect sizes are computed as the regression coefficient divided by the standard deviation in the occupation-level skill indexes"
local tableOptions  nobaselevels label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par star  

		
label values `education' skillLabel
local counter=1

local tableName "./output/skillRegressionsTable`educationType'Pooled.tex"
textablehead using `tableName', ncols(3) coltitles(`coltitles') ///
	key(tab:skillRegs) col(c) title(`tableTitle') 

esttab *Index using `tableName',  `tableOptions' keep(2.`education') ///
	stats(standard2, ///
		label( "\hspace{3mm}\textit{Effect size}\vspace{4mm}") ///
		fmt(%9.3fc %9.3fc))	
esttab *Index using `tableName',  `tableOptions' keep(3.`education') ///
		stats(standard3 r2 N, ///
		label( "\hspace{3mm}\textit{Effect size}" "\midrule Overall $ R^2$" "Observations") ///
		fmt(%9.3fc  %9.2fc %9.0fc))
textablefoot using `tableName', notes(`tableNote') dofile(`do_location')

