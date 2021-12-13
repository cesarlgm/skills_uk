*===============================================================================
*SAVING OCCUPATIONAL CROSSWALKS AND LFS SOCKEYS
*This 
*===============================================================================

*I get the occupational coding from the SES
use "data/raw/SESsurvey/ses_combined_general%20release", clear

keep if dataset>=1997
keep dataset b_soc90 bsoc2000 bsoc2010 gwtall

*===============================================================================
*Analyzing crosswalk 1997 2000
*===============================================================================
*First I create a table with the occupations that I am losing in 1990
preserve
keep if dataset==1997
keep b_soc90
g	 in97=1
duplicates drop 
save "data/temporary/bsoc9097", replace
restore

preserve
keep if dataset==2001
keep b_soc90
g	 in00=1
duplicates drop
save "data/temporary/bsoc9000", replace
restore


use "data/temporary/bsoc9097", clear
joinby b_soc90 using "data/temporary/bsoc9000" , unmatched(both)

rename _merge index
label define indexLbl 1 "In 1997 only" 2 "In 2001 only" 3 "In both"
label values index indexLbl
drop in97 in00

save "data/temporary/b_1990index", replace

use "data/raw/SESsurvey/ses_combined_general%20release", clear

preserve
keep if dataset==1997
merge m:1 b_soc90 using  "data/temporary/b_1990index"

log using "results/log_files/lostOccupations97.txt", replace text
*These are the occupations from 1997 that I am losing
table index dataset, c(count gwtall) format(%14.0fc) row
tab b_soc90 if index==1
log close
restore

*===============================================================================
*This is the cross walk I using the for the occupation panel
*===============================================================================
*Here I get the cross-walk between 1990 and 2000
keep if dataset==2001
drop bsoc2010
collapse (sum) 	employment=gwtall (count) observations=gwtall, by(bsoc2000 b_soc90)
egen 			catEmployment=sum(employment), by(b_soc90)
g	 			cwWeight=employment/catEmployment
drop 			employment catEmployment

egen				numSoc90=count(b_soc90), by(bsoc2000)
label var numSoc90 "Number soc90 codes"

preserve
duplicates drop bsoc2000, force
log using "./output/soc90count.txt", replace text
table numSoc90
log close
restore

save "data/temporary/crossWalk9000", replace
*===============================================================================

*LABOR FORCE SURVEYS
foreach year in 1997 2001 2006 2012 2017 {
	forvalues quarter=1/4{
		use "data/raw/LFS/`year'q`quarter'", clear
		rename *, lower
		if `year'==1997 {
			keep socmain
			rename socmain b_soc90
		}
		else if (`year'==2001&`quarter'>1)|`year'==2006 {
			keep soc2km
			rename soc2km 	bsoc2000
		}
		else if `year'==2012 {
			*Here I am using the cross-walk that is already provided in the 
			*LFS
			keep sc102km 
			rename sc102km  bsoc2000
		}
		else if `year'==2017 {
			*Here I am using the cross-walk that is already provided in the 
			*LFS
			keep sc102km 
			rename sc102km 	bsoc2000
		}
		duplicates drop
		g quarter`quarter'=1
		save "data/temporary/socKeyLFS`year'q`quarter'", replace
	}
}
