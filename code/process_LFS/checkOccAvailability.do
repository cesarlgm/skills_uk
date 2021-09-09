*===============================================================================
*Studying occupational classification
*===============================================================================
local occupation `1'

use "./tempFiles/finalLFSdatabaseDisag", clear

collapse (sum) people if year>=2001, by(`occupation' year)
drop people
g 	 withData=1
egen nYearsAval=sum(withData), by(`occupation')

reshape wide withData, i(`occupation') j(year)
ds withData*
foreach variable in `r(varlist)' {
	replace `variable'=0 if missing(`variable')
}

*In principle I have much more occupations doing this way
save "./tempFiles/occAvailabilityTable", replace
