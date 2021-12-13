*===============================================================================
*Constructing border indicator
*===============================================================================

local educationType `1'

ds empShare*
local educMax: word count of `r(varlist)'
local --educMax
di "`educMax'"

*Creating education indicators for borders
forvalues j=1/`educMax'{
	g 	orderEducID`j'=.
	label var educOrder`j' "Indicates position by employment share of educ `j'"
	label var orderEducID`j' "Indicates ID of education with `j'-th largest employment share"
}

forvalues educCounter=1/`educMax' {
	forvalues orderCounter=1/`educMax'{
		replace orderEducID`orderCounter'=`educCounter' if educOrder`educCounter'== ///
			`orderCounter'
	}
}


egen 		firstIndex=		rowmin(orderEducID1 orderEducID2) if nEducBorder==2
egen 		tempfirstIndex=	rowmin(orderEducID1-orderEducID3) if nEducBorder==3
replace 	firstIndex=tempfirstIndex if nEducBorder==3
drop 		tempfirstIndex

egen 		secondIndex= 		rowmax(orderEducID1 orderEducID2) if nEducBorder==2
egen 		tempsecondIndex= 	rowmedian(orderEducID1-orderEducID3) if nEducBorder==3
replace 	secondIndex=tempsecondIndex if nEducBorder==3
drop 		tempsecondIndex

egen 		thirdIndex=			rowmax(orderEducID1 orderEducID2 orderEducID3) ///
	if nEducBorder==3

	
foreach variable in firstIndex secondIndex thirdIndex {
	tostring `variable', replace
	replace	`variable'="" if `variable'=="."
}

g 		borderType=firstIndex+secondIndex+thirdIndex
replace borderType="1234" if nEducBorder==4
destring borderType, replace

*Labeling"

if `educationType'==1 {
	label define borderType 12 "Below A levels / A levels" ///
							13 "Below A levels / Bachelor+" ///
							23 "A levels / Bachelor+" ///
							123 "Three-way border"
}
else if `educationType'==2  {
	label define borderType 12 "Below GCSE C / GCSE C to A lev." ///
							13 "Below GCSE C / Bach+" ///
							23 "GCSE C to A lev. / Bach+"  ///
							123 "Three-way border"
}
else if `educationType'==3 {
	label define borderType 12 "Below GCSE C - GCSE A-C" ///
							13 "Below GCSE C - A levels" ///
							14 "Below GCSE C - Bachelor+" ///
							23 "GCSE A-C- A levels" ///
							24 "GCSE A-C- Bachelor+" ///
							34 "A levels- Bachelor+" ///
							123 "Below GCSE C - GCSE A-C - A levels" ///
							124 "Below GCSE C - GCSE A-C - Bachelor+" ///
							134 "Below GCSE C - A levels - Bachelor+" ///
							234 "GCSE A-C - A levels - Bachelor+" ///
							1234 "4-way boder"
							
}
label values borderType borderType

cap drop firstIndex secondIndex thirdIndex educOrder*

