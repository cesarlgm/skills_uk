*===============================================================================
*CHECKING CROSS WALK CONSISTENCY
*Here I am just checking how close the mapping between the SES and the LFS is
*overall everything pans out.
*===============================================================================


*Year 1997
use "./tempFiles/sesSOC90Key", clear

forvalues quarter=1/4 {
	merge 1:1 b_soc90 using "./tempFiles/socKeyLFS1997q`quarter'", nogen
	replace quarter`quarter'=0 if missing(quarter`quarter')
	
	*Almost all occupations are matched here. So, in principle I'm fine
	tab quarter`quarter'
}


use "./tempFiles/socKey00", clear

forvalues quarter=2/4 {
	merge 1:1 bsoc2000 using "./tempFiles/socKeyLFS2001q`quarter'", nogen
	replace quarter`quarter'=0 if missing(quarter`quarter')
	
	*Almost all occupations are matched here. So, in principle I'm fine
	tab quarter`quarter'
}

use "./tempFiles/socKey00", clear
forvalues quarter=1/4 {
	merge 1:1 bsoc2000 using "./tempFiles/socKeyLFS2006q`quarter'", nogen
	replace quarter`quarter'=0 if missing(quarter`quarter')
	
	*Almost all occupations are matched here. So, in principle I'm fine
	tab quarter`quarter'
}

use "./tempFiles/socKey10", clear
forvalues quarter=1/4 {
	merge 1:1 bsoc2010 using "./tempFiles/socKeyLFS2012q`quarter'", nogen
	replace quarter`quarter'=0 if missing(quarter`quarter')
	
	*Almost all occupations are matched here. So, in principle I'm fine
	tab quarter`quarter'
}

use "./tempFiles/socKey10", clear
forvalues quarter=1/4 {
	merge 1:1 bsoc2010 using "./tempFiles/socKeyLFS2017q`quarter'", nogen
	replace quarter`quarter'=0 if missing(quarter`quarter')
	
	*Almost all occupations are matched here. So, in principle I'm fine
	tab quarter`quarter'
}
