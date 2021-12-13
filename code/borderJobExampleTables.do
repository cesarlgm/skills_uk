*Border Job Examples Tables
local occupation 			`1'
local borderThreshold		`2'
local boundaryDefinition 	`3'
local educationType			`4'
local year					`5'
local twoWayBorder			`6'
local numberExamples		15

if `twoWayBorder'==0 {
	local 3way "multiple"
}
else {
	local 3way ""
}

*There's a mistake in the code. Probably the labeling of the boundary is wrong
use "./tempFiles/boundaryDummies`boundaryDefinition'`educationType'`borderThreshold'", clear

local borderJob boundaryJob`borderThreshold'

keep if year==`year'
keep year `occupation' borderType `borderJob'
keep if `borderJob'

sort `occupation'

local topHead "./output/borderJobExamplesHead.tex"
local topFoot "./output/borderJobExamplesFoot.tex"


*===============================================================================
*looping through all the possible borders
*===============================================================================
levelsof 		borderType
local valueList `r(levels)'
local labels: value label borderType
local ++numberExamples

foreach border in `valueList' {
	preserve
	keep if borderType==`border'
	*Getting the value label
	local borderLabel: label `labels' `border'
	summ 
	local tableID="`boundaryDefinition'`borderThreshold'`educationType'"
	local tabName "./output/borderJobExamples`tableID'_`border'`3way'.tex"
	cap rm `tabName'
	tabout `occupation' using `tabName' if _n<`numberExamples', ///
			style(tex) topf(`topHead') ///
			botf(`topFoot') topstr(`borderLabel') replace
	restore
}
