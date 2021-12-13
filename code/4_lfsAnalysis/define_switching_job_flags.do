*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	creates graphs with number of jobs that are switching from year 
				to year
	
	output: 	 
	
	*Graphs and tables
				 "output/shareSwithchingTotal.pdf"
				 "output/shareSwithchingByType.pdf"
				 "output/shareSwithchingByTypeSES.pdf"
				 "output/qJobsByCategory.pdf"
				 "output/numberSwitchesByType.pdf"
				 "output/switcherWeightsTable.tex"
				 "output/jobTransitions.tex"
				 
	*Labelling for other data
				

*/
*===============================================================================
local educationType  	`1'
local occupation  		`2'
local restrictSwitch	`3'
local chosen_def		`4'
local do_location		"4_lfsAnalysis/define_switching_job_flags.do"

if `educationType'==1 {
	local education newEducation
	local nLevels=3
}
else if `educationType'==2 {
	local education alternativeEducation
	local nLevels=3
}
else if `educationType'==3 {
	local education fourEducation
	local nLevels=4
}



if `restrictSwitch'==1 {
	local switchFilter &nSwitches<=3
}


use "tempFiles/borderJobClassificationLFS`educationType'", clear

egen occObservations=sum(observations), by(year `occupation')

bysort year `occupation': keep if _n==1
drop people educAggShare educOccShare populateInd totalJobCount ///
	jobCount jobShare `education'

sort `occupation' year
*Initial definition
by `occupation': g differentCategory=jobType[_n]!=jobType[_n+1] if year<2017


egen nSwitches=sum(differentCategory), by(`occupation')


local length_list 		6 6 6 10 10 10
local init_list			3 2 4 5  4  6
local switch_list		3 3 3 7  7  7
local def_length: word count `length_list'

local counter=1
local total_list

forvalues def=1/`def_length' {
	local  window_length_name:		 word `def' of `length_list'
	local  window_length=			`window_length_name'-2
	
	local initial_window_name: 		 word `def' of `init_list' 
	local initial_window= 			`initial_window_name'-1
	
	local final_window_name=		`window_length_name'-`initial_window_name'
	local final_window=				`window_length'-`initial_window'
	local n_switches:				word `def' of `switch_list'

	sort `occupation' year
	*Indicator of initial year window
	*---------------------------------------------------------------------------
	cap drop sameType
	cap drop tempFirst
	cap drop tempLast
	
	by  `occupation': g sameType=jobType[_n]==jobType[_n+1] if year<2017
	by 	`occupation': g t_1=sum(sameType) if _n<=`initial_window'
	egen				t_2=max(t_1), by(`occupation')
	g				  tempFirst=t_2==`initial_window'
	drop t_1 t_2

	*Indicator of final year window
	*---------------------------------------------------------------------------
	by 	`occupation': g t_1=sum(sameType) if inrange(_n,_N-`final_window',_N-1)
	egen				t_2=max(t_1), by(`occupation')
	g				  tempLast=t_2==`final_window'
	drop t_1 t_2
	
	local name=`initial_window_name'`final_window_name'`n_switches'

	by `occupation': g t_switcher`name'=tempFirst & tempLast & ///
	jobType[1]!=jobType[17] & nSwitches<=`n_switches'

	local total_list `total_list'  t_switcher`name'
	
	egen	switcher`name'=rowtotal(`total_list')
	replace	switcher`name'=(switcher`name'>0)
	local ++counter
}



*Classifying the jobs according to the switch type
sort `occupation' year
g 		t_initialType	=jobType 	if year==2001
g 		t_finalType	=	jobType 	if year==2017
egen 	initialType=	max(t_initialType), by(`occupation')
egen 	finalType=		max(t_finalType), 	by(`occupation')

g		restrictedType= initialType*100+finalType

keep year `occupation' jobType restrictedType switcher`chosen_def' initialType finalType

local flag switcher`chosen_def'

*-------------------------------------------------------------------------------
*Generating time of switch flag
*-------------------------------------------------------------------------------

foreach variable in initialType finalType {
	replace `variable'=. if !`flag'
}

g in_start=initialType==jobType 	if `flag'
g in_end=finalType==jobType			if `flag'


tempvar t_first_moved_out
tempvar t_last_moved_out
tempvar t_first_moved_in
tempvar t_last_moved_in

g `t_first_moved_out'=	year 	if `flag'&!in_start
g `t_last_moved_out'=	year+1 	if `flag'&in_start
g `t_first_moved_in'=	year 	if `flag'&	in_end
g `t_last_moved_in'=	year+1 	if `flag'&	!in_end


*I try four options
*-------------------------------------------------------------
*First year out of initial type
egen first_out=min(`t_first_moved_out'), by(`occupation')
*First year out of initial type
egen last_out=max(`t_last_moved_out'), by(`occupation')

*First year in last type
egen first_in=min(`t_first_moved_in'), by(`occupation')
*Last year out of initial type
egen last_in=max(`t_last_moved_in'), by(`occupation')


*Outputting flag file
*-------------------------------------------------------------
keep `occupation' `flag' restrictedType initialType finalType first* last*
duplicates drop

replace restrictedType=. if !`flag'

label define restrictedType 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid"

label values restrictedType restrictedType 

label data "Generated with `do_location'"
save "tempFiles/transition_time_flags", replace
