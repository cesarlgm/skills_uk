
local occupation	`1'
local threshold 	`2'
local boundaryType	`3'
local educationType `4'

use "./tempFiles/boundaryDummies`boundaryType'`educationType'`threshold'", clear

keep year `occupation' boundaryJob`threshold'
keep if year>=2001

preserve
keep year
duplicates drop
save "./tempFiles/yearTableYearKey", replace
restore

preserve
keep `occupation'
duplicates drop
save "./tempFiles/occupationTableYearKey", replace
restore

clear
use  "./tempFiles/yearTableYearKey"
cross using "./tempFiles/occupationTableYearKey"

merge 1:1 year `occupation' ///
	using "./tempFiles/boundaryDummies`boundaryType'`educationType'`threshold'"
drop if year<2001
drop _merge

sort  `occupation' year
keep year `occupation' boundaryJob`threshold'

local sumList boundaryJob`threshold'[_n]+ boundaryJob`threshold'[_n+1]
forvalues j=2/10 {
	by `occupation': g tempInBorder`j'=`sumList'
	local sumList `sumList' + boundaryJob`threshold'[_n+`j']
	g 	inBorder`j'=tempInBorder`j'==`j'
	drop tempInBorder`j'
}

local sumList !boundaryJob`threshold'[_n]+ !boundaryJob`threshold'[_n+1]
forvalues j=2/10 {
	by `occupation': g tempNotInBorder`j'=`sumList'
	local sumList `sumList' + !boundaryJob`threshold'[_n+`j']
	g 	notInBorder`j'=tempNotInBorder`j'==`j'
	drop tempNotInBorder`j'
}

collapse (count) boundaryJob`threshold' (mean) inBorder* ///
	if boundaryJob`threshold', by(year)

local width lwidth(medthick)
local graphNote "Note: vertical lines denote breaks in the occupational classification"
tw 	(line inBorder2 year if year<=2016, `width') ///
	(line inBorder3 year if year<=2015, `width' lpattern(dash)) ///
	(line inBorder4 year if year<=2014, `width' lpattern(shortdash)) ///
	(line inBorder5 year if year<=2013, `width' lpattern(longdash)) ///
	(line inBorder6 year if year<=2012, `width' lpattern(.)) ///
	(line inBorder7 year if year<=2011, `width' lpattern(.-)) ///
	(line inBorder8 year if year<=2010, `width' lpattern(.--.)) ///
	, xline(2011) legend( order( ///
	1 "2 years" ///
	2 "3 years" ///
	3 "4 years" ///
	4 "5 years" ///
	5 "6 years" ///
	6 "7 years" ///
	7 "8 years" ///
	)) note(`graphNote') yscale(range(0 1)) ylabel(0(.1)1)

graph export "./output/shareJobsBoundaryEd`educationType'.pdf", replace

label  var	boundaryJob`threshold' "Job count"
tw 	(line boundaryJob`threshold' year if year<=2016), ///
	xline(2011) note(`graphNote') yscale(range(0 90)) ylabel(0(10)90)
graph export "./output/numberJobsBoundaryEd`educationType'.pdf", replace
