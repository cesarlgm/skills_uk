*===============================================================================
*CREATE SES SKILLS
*===============================================================================

/*
*Performs
	- Factor analysis
	- Creates factors and selects some variables
*/
*===============================================================================


local occupation 		`1'
local filter 			`2'
local obsThreshold		`3'
local aggregateSOC		`4'
local educationType		`5'

use "./output/skillSESDatabase", clear

label var ccalca "importance of: arithmetic (adding substracting)"

local analyticalList 	cpeople cteach cpersuad cplanoth canalyse csolutn ///
						ccalca cpercent cwritelg cwritesh clong cshort
local manualList		cstam cstreng chands ctools
local routinePC			dusepc

label var dusepc "complexity of PC use"

sutex `analyticalList', labels digits(0) file(output/vittoriaList.tex) replace ///
	 title(Analytical variables) nobs
sutex `manualList', labels digits(0) file(output/vittoriaList.tex) append  ///
	 title(Manual variables) nobs
sutex `routinePC', labels digits(0) file(output/vittoriaList.tex) append  ///
	title(Routine variables) nobs
