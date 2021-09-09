*===============================================================================
*FILTERING THE LFS DATA	
*This file filters the LFS by:
* 	- Age
*	- education
*	- work experience
*	- occupation
*===============================================================================

local year 		`1'
local quarter 	`2'

*I keep only people between 20 - 60
keep if inrange(age, 20,60)

*I drop people with unknown educational level
drop if edlevLFS==.
		
*Some filters are missing here
keep if inrange(age, 20, 60)

*Government schemes: these are the people who are employed in government-sponsored
*training programs. I will exclude them from my sample.
*I am selecting only:
*	-Self-employed
*	-Employees
keep if inlist(statr, 1, 2)

*I also drop people who are still in education
drop if inlist(edage, -9, -8, 96)


g impliedExperience=age-edage

*I keep people that has at least one year of implied experience
keep if impliedExperience>=1
	
*Finally I filter people in the army
if `year'<=2000{
	*I am excluding people:
	*With unknown occupation, in the armed forces, and vague categories such as
	*all other labourers etc, all others (miscellaneous)
	drop if inlist(socmain, -9,-8, 150,151,600,601, 900,999)
}
else if (`year'==2001 & `quarter'!=1)|inrange(`year',2002,2010){
	drop if inlist(soc2km, -9,-8, 1171, 3311)
}
else if inrange(`year',2011,2017) {
	drop if inlist(soc10m,-9,-8,1171,3311)
}
