*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	creates graphs with number of jobs that are switching from year 
				to year
	
	output: 	 
	
	*Graphs and tables

				 
	*Labelling for other data
				

*/
*===============================================================================
local educationType  	`1'
local occupation  		`2'
local restrictSwitch	`3'
local chosen_def		`4'
local do_location=		"4\_lfsAnalysis/transition\_time\_graphs.do"

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



if `restrictSwitch'==1 {
	local switchFilter &nSwitches<=3
}


use "tempFiles/transition_time_flags", clear

label define restrictedType 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid"

label values restrictedType restrictedType 


expand 17
bysort `occupation': g	year=2000+_n

foreach variable in first_in last_in first_out last_out {
	g	trans_`variable'=year>=`variable'
}

keep if !missing(restrictedType)

collapse (sum) trans_* , by(year restrictedType)

label var trans_first_in 	"First in"
label var trans_first_out 	"First out"
label var trans_last_in 	"Last in"
label var trans_last_out 	"Last out"

do "codeFiles/graphColorScheme.do"

local figure_title 	"Number of transitioned occupations by transition type"
local figure_note	"Transitions are defined as the union of 3-3-3, 4-2-3 and 2-4-3. Vertical lines indicate years for which I have SES data."
local figure_name	"output/transition_timeline.tex"

tw line trans_* year if inlist(restrictedType,112,2303),  ///
	by(restrictedType) xline(2001 2006 2012 2017) recast(connected)
graph export "output/transition_timeline.pdf", replace
	
latexfigure using `figure_name', path(../output) figurelist(transition_timeline) ///
	title(`figure_title') note(`figure_note') dofile(`do_location')

