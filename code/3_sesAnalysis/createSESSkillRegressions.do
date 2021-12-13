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
local do_location		"3\_sesAnalysis/createSESSkillRegressions.do"

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
	label define skillLabel 1 "\hspace{3mm}Below GCSE C" 2 "\hspace{3mm}GCSE C-A levels" ///
	3 "\hspace{3mm}Bachelor+"
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


local typeList 12 23 1 2 3

if `regressionType'==1 {
	foreach index in averageList restrictedList orthogonalList {
		egen tempTotal=rowtotal(``index'')
		foreach variable in ``index'' {
			replace `variable'=`variable'/tempTotal
		}
		drop tempTotal
	}
}

local filter23 &inlist(`education',2,3)
local filter12 &inlist(`education',1,2)
local filter13 &inlist(`education',1,2,3)
local filter1 `filter13'
local filter2 `filter13'
local filter3 `filter13'

*Creating regressions
foreach skill in `averageList' `restrictedList' `orthogonalList' `averageListSd' {
	*First I compute the standard deviation
	preserve
		collapse (mean) `skill' (count) observations=year, by(`occupation')
		summ `skill' [aw=observations]		
		local occ_sd=`r(sd)'
	restore
	
	foreach type in `typeList' {
		cap qui eststo `skill'`type': areg `skill' i.`education'  i.year  ///
			if jobType==`type'`filter`type'', absorb(`occupation') vce(r)
			

		*Standardizing the coefficient
		*Firt I get the maximum education
		summ `education' if jobType==`type'`filter`type''
		local max_education=`r(max)'
		
		
		local standard=_b[`max_education'.`education']/ `occ_sd'
		cap estadd scalar occ_sd= `occ_sd'
		cap estadd scalar standard= `standard'
		cap qui eststo `skill'`type'
	}
}

*Creation of the tables
local coltitles=`""Analytical""Manual""Routine""'

local tableTitle "Relative skill use in border jobs across education groups (simple average indexes)"
local tableNote "all skill indexes range between 0 and 1. Regressions use individual-level data. Robust standard errors in parenthesis. Coefficents represent the difference relative the lower education level. I use dummy of basic to moderate PC use complexity as measure of routineness. I pool data from all years. Regressions include occupation fixed-effects. Effect sizes are computed as the regression coefficient divided by the standard deviation in the occupation-level skill indexes"
local tableOptions drop(_cons *year)  nobaselevels label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par star  ///
		stats( standard r2 N, ///
		label( "\hspace{3mm}Effect size" "\midrule Overall $ R^2$" "Observations") ///
		fmt(%9.3fc %9.2fc %9.2fc %9.0fc))

local titleLabs `""Below GCSE C / GCSE C-A lev. border" "GCSE C to A lev. / Bachelor+ border""'
local subtitleLabs `""Below GCSE C" "GCSE C to A lev.""'
		
label values `education' skillLabel
local counter=1

local tableName "./output/skillRegressionsTable`educationType'`regressionType'.tex"
textablehead using `tableName', ncols(3) coltitles(`coltitles') ///
	key(tab:skillRegs) col(c) title(`tableTitle') 

foreach type in 12 23 {
	if `counter'>1 {
		local midrule \midrule
	}
	local titleLab: word `counter' of `titleLabs'
	local subtitleLab: word `counter' of `subtitleLabs'
	local ++counter
	writeln `tableName' "`midrule'\textit{`titleLab'}\vspace{1mm} \\ "
	*writeln `tableName' "\hspace{3mm}\textbf{Base level: }`subtitleLab' \\ "
	esttab *Index`type' using `tableName',  `tableOptions'
}
textablefoot using `tableName', notes(`tableNote') dofile(`do_location')


*Creation of the tables
local coltitles=`""Analytical""Manual""Routine""'

local tableTitle "Relative skill use in border jobs across education groups (index with standardized variables)"
local tableNote "all skill indexes range between 0 and 1. Regressions use individual-level data. Robust standard errors in parenthesis. Coefficents represent the difference relative the lower education level. I use dummy of basic to moderate PC use complexity as measure of routineness. I pool data from all years. Regressions include occupation fixed-effects. Effect sizes are computed as the regression coefficient divided by the standard deviation in the occupation-level skill indexes"
local tableOptions drop(_cons *year)  nobaselevels label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par star  ///
		stats( standard r2 N, ///
		label( "\hspace{3mm}Effect size" "\midrule Overall $ R^2$" "Observations") ///
		fmt(%9.3fc %9.2fc %9.2fc %9.0fc))

local titleLabs `""Below GCSE C / GCSE C-A lev. border" "GCSE C to A lev. / Bachelor+ border""'
local subtitleLabs `""Below GCSE C" "GCSE C to A lev.""'
		
label values `education' skillLabel
local counter=1

local tableName "./output/skillRegressionsTable`educationType'`regressionType'Standardized.tex"
textablehead using `tableName', ncols(3) coltitles(`coltitles') ///
	key(tab:skillRegs) col(c) title(`tableTitle') 

foreach type in 12 23 {
	if `counter'>1 {
		local midrule \midrule
	}
	local titleLab: word `counter' of `titleLabs'
	local subtitleLab: word `counter' of `subtitleLabs'
	local ++counter
	writeln `tableName' "`midrule'\textit{`titleLab'}\vspace{1mm} \\ "
	*writeln `tableName' "\hspace{3mm}\textbf{Base level: }`subtitleLab' \\ "
	esttab *Index_sd`type' using `tableName',  `tableOptions'
}
textablefoot using `tableName', notes(`tableNote') dofile(`do_location')
