*===============================================================================
*Per year filter of occupation
*Filter people with no education
*===============================================================================

local year `1'


if `year'==1997 {
	rename socmain occupation 
	
	*I drop people with no stated occupation
	drop if inlist(occupation, -8, -9)
	
	*I also drop people in the armed forces
	drop if inlist(occupation, 150, 151, 600)
	
	label var occupation "occ main job base year 1990"
	
}
else if `year'==2001 | `year'==2006 {
	cap rename soc2km occupation 
	
	*I drop people with no stated occupation
	cap drop if inlist(occupation, -8, -9)
	
	*People in the armed forces
	*NCO are non-comission officers
	cap drop if inlist(occupation, 1171, 3311)
	
	cap label var occupation "occ main job base year 2000"
}
else if `year'==2012 {
	rename soc10m occupation
	
	*I drop people with no stated occupation
	drop if inlist(occupation, -8, -9)
	
	*People in the armed forces
	*NCO are non-comission officers
	drop if inlist(occupation, 1171, 3311)
	
	label var occupation "occ main job base year 2010"
}
