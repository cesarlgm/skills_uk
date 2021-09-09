*===============================================================================
*This creates the employment correlation tables
*===============================================================================

local education 	`1'
local occupation 	`2'

use "./tempFiles/educEmploymentSharesLFS", clear

drop educPeople educObs age

reshape wide people educEmpShare  observations educObsShare, ///
	i(year `occupation') j(`education')

label var educEmpShare0 "No qualification"
label var educEmpShare1 "GCSE D-G levels"
label var educEmpShare2 "GCSE A-C levels"
label var educEmpShare3 "GCE A* / trade apprenticeship"
label var educEmpShare4 "Bachelor's or more"

	
log using "./output/correlationTablesLFS.txt", text replace
pwcorr educEmpShare*

bysort year: pwcorr educEmpShare*

pwcorr educObsShare*

bysort year: pwcorr educObsShare*

log close

*Compute occupational employment shares
*Create an occupation panel so that I have all occupations in all years for all
*educations
*Redo the boundary graphs
