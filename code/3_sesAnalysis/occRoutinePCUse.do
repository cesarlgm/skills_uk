*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	looks at the type of occupations with a very high routine use 
				measure
	
	output: 

*/
*===============================================================================

local occupation 		`1'
local filter 			`2'
local aggregateSOC		`3'
local educationType		`4'
local regressionOptions vce(r) nocons
local do_location		"3\_sesAnalysis/occRoutinePCUse.do"

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

g twoDigitOcc=`occupation'
tostring 	twoDigitOcc, replace
g			threeDigitOcc=substr(twoDigitOcc,1,3)
replace 	twoDigitOcc=substr(twoDigitOcc,1,2)
g			oneDigitOcc=substr(twoDigitOcc,1,1)
destring 	threeDigitOcc, 	replace
destring	twoDigitOcc, 	replace
destring	oneDigitOcc, 	replace

do "codeFiles/labelOccGroups.do"

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

g medEduc=`education'==2

collapse (mean)  *use medEduc, by(twoDigitOcc)

set graphics on

gsort -bmuse
g 	   occRank=_n

decode twoDigitOcc, g(temp)
replace temp=substr(temp,3,.)
labmask occRank, values(temp)
drop temp

graph  dot  bouse bmuse controutineuse mouse, over(occRank) hor ///
	legend(order(1 "Basic only" 2 "Basic-moderate" 3 "Continuous"  4 "Moderate only")) ///
	marker(1,msymbol(o) mcolor(ebblue)) marker(2,msymbol(d) mcolor(red)) ///
	marker(3,msymbol(s) mcolor(edkblue))  marker(4,msymbol(t) mcolor(gold))

graph export "output/occRankingComparison.pdf", replace

local figureTitle="PC use complexitity across different occupation groups"
local figureLabs=`""PC use""PC use complexity""PC use in different occupation groups""'
local figureNotes="basic use involves routine procedures such as printing and invoicing. Moderate use involves use of email and word processing and/or spreadsheets. Complex use involves use for statistical analysis."

*Here I ouptut the latex code for the figure
latexfigure using "output/routinePCUseComparisons.tex", path(../output) ///
	figurelist(PCUseComparisons routinePCUseComparisons occRankingComparison) title(`figureTitle') ///
	key(fig:pccomparison) figlab(`figureLabs') note(`figureNotes') rowsize(2) ///
	dofile(`do_location')

