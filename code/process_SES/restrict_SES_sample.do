*===============================================================================
*SAMPLE RESTRICTIONS
*===============================================================================
local occupation `1'
local do_location="process\_SES/restrict\_SES\_sample.do"

*I restrict the sample to people aged 20-60 to keep consistency across years
keep if inrange(age,20,60)

drop if missing(`occupation')

*I also restrict it to people who have been working for at least a year.
keep if dpaidwk>=1

drop if missing(edlev)

if "`occupation'"=="isco88" {
*Dropping Armed forces
	drop if  `occupation'==100
	drop if  `occupation'==10000
}
else if inlist("`occupation'","bsoc2000","bsoc00Agg") {
	*I am dropping the armed forces
	drop if `occupation'==1171
	drop if `occupation'==3311
	drop if `occupation'==10000
}

order emptype, after(bsoc2010)

*These are variables with a lot of missing observations
drop cnoac* bauto cpcsk* bsuper cdetail cmefeel cmotivat cnetuse  cnoerror ///
	cthings ccoop cmistake cforlan sk* ccoach cmefeel cothfee ccareers cfuture clookpr ///
	csoundp 

ds bchoice-gwtall
local skillList `r(varlist)'
foreach variable in `skillList' {
	di "`variable'"
	drop if `variable'==.
}

label data "Produced with `do_location'"
save "data/temporary/filtered_dems_SES", replace
