*===============================================================================
*Tables and graphs based on border job classification
*===============================================================================

local educationType 	`1'
local occupation		`2'


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
summ totalJobCount
local jobCount=r(mean)

*===============================================================================
*Graph of border jobs persistence
*===============================================================================
preserve
keep year `occupation' borderJob totalJobCount
duplicates drop

sort `occupation' year

local sumList borderJob[_n]+ borderJob[_n+1]

*This creates dummies indicating how long have you been in the border
forvalues j=2/10 {
	by `occupation': g tempInBorder`j'=`sumList'
	local sumList `sumList' + borderJob[_n+`j']
	g 	inBorder`j'=tempInBorder`j'==`j'
	drop tempInBorder`j'
}

collapse (sum) borderJob (sum) inBorder*, by(year)
ds inBorder* 
foreach variable in `r(varlist)'{
	replace `variable'=. if  `variable'==0
	replace `variable'=`variable'/borderJob
}

local width lwidth(medthick)
local graphNote "Note: the dataset includes `jobCount' jobs in total."
tw 	(line inBorder2 year, `width') ///
	(line inBorder3 year, `width' lpattern(dash)) ///
	(line inBorder4 year, `width' lpattern(shortdash)) ///
	(line inBorder5 year, `width' lpattern(longdash)) ///
	(line inBorder6 year, `width' lpattern(-.-)) ///
	(line inBorder7 year, `width' lpattern(.-)) ///
	(line inBorder8 year, `width' lpattern(.--.)) ///
	, legend( order( ///
	1 "2 years" ///
	2 "3 years" ///
	3 "4 years" ///
	4 "5 years" ///
	5 "6 years" ///
	6 "7 years" ///
	7 "8 years" ///
	)) note(`graphNote') yscale(range(0 .9)) ylabel(0(.1).9) ///
	xscale(range(2001 2017)) xlabel(2001(2)2017)
graph export "output/jobClassificationBorderPersistence`educationType'.pdf", replace
restore

*===============================================================================
*Tables with examples
*===============================================================================
local nExamples=15

*Cutting the value labels
levelsof `occupation'
local occList=r(levels)
foreach occ in `occList' {
	local occLabel: value label `occupation'
	local occValueLabel: label `occLabel' `occ'
	local occValueLabel=substr("`occValueLabel'",1,40)
	label define `occLabel' `occ' "`occValueLabel'", modify
}


*For the examples I choose 2009, beeing the "middle" year
keep if year==2009
keep if borderJob
keep observations `education' jobType `occupation'
reshape wide observations, i(`occupation') j(`education')

sort `occupation'
*Low-Mid table
local tabName="output/borderExamples`educationType'_12.tex"
local topHead="output/borderExamples_12Head.tex"
local topFoot="output/borderExamples_Foot.tex"

preserve
keep if jobType==12
tabout `occupation' using `tabName' if _n<`nExamples'&jobType==12, style(tex) topf(`topHead') ///
		botf(`topFoot') topstr(`skillLab') ///
		replace cells(mean observations1 mean observations2) sum ///
		h1(nil) h2(nil) h3(nil) ptotal(none) format(0)
restore
preserve
keep if jobType==23
*Mid-High table
local tabName="output/borderExamples`educationType'_23.tex"
local topHead="output/borderExamples_23Head.tex"
local topFoot="output/borderExamples_Foot.tex"

tabout `occupation' using `tabName' if _n<`nExamples'&jobType==23, style(tex) topf(`topHead') ///
		botf(`topFoot') ///
		replace cells(mean observations2 mean observations3) sum ///
		h1(nil) h2(nil) h3(nil) ptotal(none) format(0)
restore
preserve
keep if jobType==13
*Low-High table
local tabName="output/borderExamples`educationType'_13.tex"
local topHead="output/borderExamples_13Head.tex"
local topFoot="output/borderExamples_Foot.tex"

tabout `occupation' using `tabName' if _n<`nExamples'&jobType==13, style(tex) topf(`topHead') ///
		botf(`topFoot') topstr(`skillLab') ///
		replace cells(mean observations1 mean observations3) sum ///
		h1(nil) h2(nil) h3(nil) ptotal(none) format(0)
restore
