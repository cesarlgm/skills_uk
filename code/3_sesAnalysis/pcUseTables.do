*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	creates graphs and tables on pc use
	
	output: 

*/
*===============================================================================

local occupation 		`1'
local filter 			`2'
local aggregateSOC		`3'
local educationType		`4'
local regressionOptions vce(r) nocons
local do_location=		"3\_sesAnalysis/pcUseTables.do"

local indivAgg=0

if `educationType'==1 {
	local education newEducation
}
else if `educationType'==2 {
	local education alternativeEducation
}
else if `educationType'==3 {
	local education fourEducation
}

if `aggregateSOC'==1 {
	local occupation bsoc00Agg
}

use "./output/skillSESDatabase", clear
drop if missing(gwtall)

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

g	graphSep=jobType==`education'

*===============================================================================
*COMPUTER USE
*===============================================================================
g	usepc=(cusepc>=2)
label define usepc 0 "No use" 1 "PC use"
label values usepc usepc

g		routinePC=dusepc>3
replace routinePC=0 if missing(dusepc)

label define education ///
	1 "Below GCSE C" ///
	2 "GCSE C to A lev." ///
	3 "Bachelor+"
	
label values `education' education

*===============================================================================
*SOME NICE GRAPHS HERE
*===============================================================================
levelsof jobType
local graphList 
*Routine pc use
foreach job in `r(levels)' {
	if `job'!=13{
		cap qui regress routinePC ibn.`education' i.`occupation' i.year ///
			if jobType==`job', `regressionOptions'
		coefplot, keep(*`education') vert mcolor(ebblue)  ciopts(color(edkblue)) ///
			yscale(range(0 1)) ylab(0(.2)1) 
		graph export "output/routinepcuse`job'.pdf", replace
		
		local graphList `graphList' routinepcuse`job'
	}
}

local figureNote="graphs show regression coefficients. Regressions include occupation and year fixed effects. CI based on robust standard errors. I assign a 0 to individuals who do not use a computer. I define routine use as declaring that one's pc use complexity is straightforward or moderate"
local graphLabel=`""Below GCSE C""GCSE C-A levels""Bachelor+""Below GCSE C/GCSE C-A levels""GCSE C-A levels/Bachelor+""'
latexfigure using "output/routinepcuseFigures.tex", ///
	path(../output) figurelist(`graphList') ///
	figlab(`graphLabel') rowsize(2) title("Routine pc use by job type") ///
	note(`figureNote') dofile(`do_location')
	
	
*===============================================================================
levelsof jobType
local graphList 
foreach job in `r(levels)' {
	if `job'!=13{
		cap qui regress usepc ibn.`education' i.`occupation' i.year ///
			if jobType==`job', `regressionOptions'
		coefplot, keep(*`education') vert mcolor(ebblue)  ciopts(color(edkblue)) ///
			yscale(range(0 1)) ylab(0(.2)1) 
		graph export "output/pcuse`job'.pdf", replace
		
		local graphList `graphList' pcuse`job'
	}
}
local figureNote="graphs show regression coefficients. Dependent variable is a dummy variable equal to 1 if a pc is used. Regressions include occupation and year fixed-effects. CI based on robust standard errors. Higher values indicate less complex pc use."
local graphLabel=`""Below GCSE C""GCSE C-A levels""Bachelor+""Below GCSE C/GCSE C-A levels""GCSE C-A levels/Bachelor+""'
latexfigure using "output/pcuseFigures.tex", ///
	path(../output) figurelist(`graphList') ///
	figlab(`graphLabel') rowsize(2) title("PC use by job type")  ///
	note(`figureNote') dofile(`do_location')
	

*===============================================================================
*Graph using continuous measure
*===============================================================================
g 		contRoutinePC=dusepc
replace	contRoutinePC=1 if dusepc==.a

levelsof jobType
local graphList 
*Routine pc use
foreach job in `r(levels)' {
	if `job'!=13{
		cap qui regress contRoutinePC ibn.`education' i.`occupation' i.year ///
			if jobType==`job', `regressionOptions'
		coefplot, keep(*`education') vert mcolor(ebblue)  ciopts(color(edkblue)) ///
			yscale(range(1 5)) ylab(1(1)5) 
		graph export "output/routinepcuseCont`job'.pdf", replace
		
		local graphList `graphList' routinepcuseCont`job'
	}
}

local figureNote="graphs show regression coefficients. Regressions include occupation and year fixed effects. CI based on robust standard errors. Higher values indicate less complex pc use. I assign a value of 1 to people who do not use a computer."
local graphLabel=`""Below GCSE C""GCSE C-A levels""Bachelor+""Below GCSE C/GCSE C-A levels""GCSE C-A levels/Bachelor+""'
latexfigure using "output/routinepcuseContFigures.tex", ///
	path(../output) figurelist(`graphList') ///
	figlab(`graphLabel') rowsize(2) title("Routine pc use by job type (continuous measure)") ///
	note(`figureNote') dofile(`do_location')

	
*Discarded interaction graphs
