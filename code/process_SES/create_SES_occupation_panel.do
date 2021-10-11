local occupation 	bsoc2000 `1'
local aggregateSOC 	1 // `2'
local do_location=	"process_SES/create\_SES\_occupation\_panel.do"


if `aggregateSOC'==1 {
	local occupation bsoc00Agg
}

*Looking at the occupations that appear in all years
use "data/temporary/filtered_dems_SES", clear
*===============================================================================
*First I get the number of times that an occupation appears
*===============================================================================
cap rename dataset year

do "code/aggregate_SOC2000.do"

*===============================================================================
*Moving to SES.
*===============================================================================
collapse (sum) tappears=gwtall, by(`occupation' year)

replace tappears=0 if tappears==0|tappears==.

egen total_people=sum(tappears), by(year)
g	 ses_emphare=tappears/total_people
drop total_people tappears

g appears=ses_emphare>0


table year, contents(sum appears)


reshape wide ses_emphare appears, i(`occupation') j(year)
order ses_emphare* appears*, after(`occupation')
ds appears*  ses_emphare*
foreach variable in `r(varlist)' {
	replace `variable'=0 if `variable'==.
}

save "data/temporary/SES_occ_availability_table.dta", replace

drop appears1997

*Table with occupation panel of the SES
*--------------------------------------
egen n_years=rowtotal(appears*)
keep `occupation' n_years

cap log close
log using "results/log_files/n_occupations.txt", text replace
tab n_years
log close

save "data/temporary/SES_occupation_key", replace

