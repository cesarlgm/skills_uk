*===============================================================================
*Computing occupation employment shares by education
*===============================================================================
local education 	`1'
local occupation 	`2'

use "./tempFiles/finalLFSdatabase", clear

preserve
keep edlevLFS
duplicates drop
save "./tempFiles/educationKey", replace
restore

preserve
keep `occupation'
duplicates drop
save "./tempFiles/occupationKey", replace
restore

preserve
keep year
duplicates drop
save "./tempFiles/yearKey", replace
restore

use "./tempFiles/yearKey", clear
cross using "./tempFiles/occupationKey"
cross using "./tempFiles/educationKey"

merge 1:1 year `education' `occupation' using  "./tempFiles/finalLFSdatabase"

foreach variable in people observations {
	replace `variable'=0 if missing(`variable')
}
drop _merge

egen educPeople=sum(people), by(`education' year)
egen educObs=sum(observations), by(`education' year)

g	educEmpShare=people/educPeople
g	educObsShare=observations/educObs


save "./tempFiles/educEmploymentSharesLFS", replace
