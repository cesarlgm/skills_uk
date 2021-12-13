*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	explores definition of routine pcuse
	
	output: 

*/
*===============================================================================

local occupation 		`1'
local filter 			`2'
local aggregateSOC		`3'
local educationType		`4'
local regressionOptions vce(r) nocons
local do_location= "3\_sesAnalysis/graphsRoutinePCUse.do"		


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

*===============================================================================
*ROUTINE COMPUTER USE
*===============================================================================
*I create two possible indexes
cap drop bmuse
cap drop bcuse
cap drop bouse
cap drop controutineuse
cap drop mouse

g pcuse=cusepc>=2
g imppcuse=cusepc>=3

g bcuse=		 		dusepc>=2
replace bcuse=0 		if cusepc==1

g bmuse=  				dusepc>=3
replace bmuse=0 		if cusepc==1

g bouse=			 	dusepc>=4
replace bouse=0 if 		cusepc==1

g mouse=				inrange(dusepc, 3,4)
replace mouse=0 if 		cusepc==0


g 			controutineuse= 			(dusepc-1)/4
replace		controutineuse=0			if cusepc==1

local meanList  	bouse bmuse bcuse mouse controutineuse pcuse imppcuse
local semeanList	sebouse=bouse sebmuse=bmuse sebcuse=bcuse ///
					secontroutineuse=controutineuse sepcuse=pcuse seimppcuse=imppcuse ///
					semouse=mouse
preserve
*I compute the means here
collapse (mean) `meanList' (semean) `semeanList', by(`education')

foreach variable in `meanList' {
	g 	upci`variable'=`variable'+1.96*se`variable'
	g 	loci`variable'=`variable'-1.96*se`variable'
}
 
label var bouse 			"Basic use only (dummy)"
label var bmuse 			"Basic to moderate use (dummy)"
label var bcuse 			"Basic to complex use (dummy)"
label var controutineuse 	"Continuous measure"
label var mouse				"Moderate use only (dummy)"
label var pcuse				"Uses computers"
label var imppcuse			"Computers are essential in job"

 
twoway (connected bouse bmuse bcuse controutineuse mouse `education',  msymbol(o dh s + Th) ///
	mcolor(ebblue edkblue red cranberry gold) lcolor(ebblue edkblue red cranberry gold)),  ///
	xlab(1/3, ang(h) valuelabel noticks) ///
	ylab(0(.2)1) xscale(range(0.7 3.3)) ///
	xtitle("") ytitle("Sample average") 

graph export "output/routinePCUseComparisons.pdf", replace

set graphics on
twoway (connected pcuse imppcuse  `education',  msymbol(o dh) mcolor(ebblue) lcolor(ebblue)),  ///
	xlab(1/3, ang(h) valuelabel noticks) ylab(0(.2)1) xscale(range(0.7 3.3)) ///
	xtitle("") ytitle("Sample average") 

graph export "output/PCUseComparisons.pdf", replace	

local figureTitle="Comparison of different pc use measures"
local figureLabs=`""PC use""PC use complexity""'
local figureNotes="basic use involves routine procedures such as printing and invoicing. Moderate use involves use of email and word processing and/or spreadsheets. Complex use involves use for statistical analysis."

*Here I ouptut the latex code for the figure
latexfigure using "output/routinePCUseComparisons.tex", path(../output) ///
	figurelist(PCUseComparisons routinePCUseComparisons) title(`figureTitle') ///
	key(fig:pccomparison) figlab(`figureLabs') note(`figureNotes') dofile(`do_location')
restore
