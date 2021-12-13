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
local chosen_def		`3'
local fixed_def			`4'
local do_location= "4\_lfsAnalysis/relaxing\_core\_jobs.do"	

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



use "tempFiles/borderJobClassificationLFS`educationType'", clear
*=====================================================================

egen occObservations=sum(educ_occ_obs), by(year `occupation')

bysort year `occupation': keep if _n==1
drop educ_occ_people educAggShare educOccShare populateInd totalJobCount ///
	jobCount jobShare `education'

levelsof jobType

egen time_core=			count(year), by(`occupation' jobType)
egen core_candidate=	max(time_core), by(`occupation')
g	 t_core_type=		jobType if core_candidate==time_core
egen	 core_type=			max(t_core_type), by(`occupation')
label values core_type jobType

g 	 time_in_core=core_candidate

sort `occupation' year
by `occupation': g	t_candidate=jobType[1]==jobType[17]
egen			candidate=max(t_candidate), by(`occupation')
keep `occupation'  time_in_core core_type candidate

duplicates drop

merge 1:1 `occupation' using "tempFiles/transition_flags", nogen

forvalues cut=9/17 {
	g core_`cut'=core_type if time_in_core>=(`cut')
}
*-------------------------------------------------------------------------------
*Question: 	how much overlap is there between job type and border for each core 
*			type
*-------------------------------------------------------------------------------
preserve 
forvalues j=13/17 {
	replace core_`j'=. if !switcher`chosen_def'
}


local table_name 	"output/table_intersection_with_border`chosen_def'.tex"
local table_title	"Intersection between core and transition type definitions"
local table_note333	"transitioning jobs defined using 3-3-3 definition."
local table_note423	"transitioning jobs are defined as the union of 3-3-3, 2-4-3 and 4-2-3 definitions"
local coltitles		"17 16 15  14 13"

textablehead using `table_name', ncols(5) title(`table_title') coltitles(`coltitles') ///
	drop sup(Years as core) f("Core type")

tabout core_type using `table_name', style(tex) bt h1(nil) h2(nil) h3(nil) ///
	cells(count core_17 count core_16 count core_15 count core_14 count core_13) ///
	append sum format(0) total(`""\midruleTotal""')
textablefoot using `table_name', notes(`table_note`chosen_def'')

*Output flag of job in intersection
rename core_14 intersection_14 

keep `occupation' intersection_14 core_type
label data "Generated using `do_location'"
save "tempFiles/definition_intersection_`chosen_def'", replace
restore

*Based on this I would recommend 16

*-------------------------------------------------------------------------------
*Question: 	how many jobs do I get by type after excluding the intersection.
*-------------------------------------------------------------------------------
drop core_9-core_17

*I forcibly exclude the intersection
forvalues cut=9/17 {
	g core_`cut'=core_type if time_in_core>=(`cut')&!switcher`chosen_def'
}

*Output flag of which jobs I am adding going from 16 to 14.
g	new_core=missing(core_16)&!missing(core_14)

preserve 
keep `occupation' new_core
tempfile new_core_flag
save `new_core_flag'
restore


*I export this in a table
local table_name 	"output/number_core_jobs`chosen_def'.tex"
local table_title 	"Number of core jobs by type and time in core threshold"
local col_titles 	"17 16 15 14 13"
local table_notes333	"I force the intersection of the core and 3-3-3 transition definition to be empty"
local table_notes423	"I force the intersection of the core and 4-2-3 transition definition to be empty"

textablehead using `table_name', ncols(5) title(`table_title') ///
	coltitles(`col_titles')  drop sup(Years as core) f("Core type")

tabout core_type using `table_name', style(tex) bt h1(nil) h2(nil) h3(nil) ///
	cells(count core_17 count core_16 count core_15 count core_14 count core_13) ///
	append sum format(0) total(`""\midruleTotal""')
	
textablefoot using `table_name', notes(`table_notes`chosen_def'') dofile(`do_location')

*-------------------------------------------------------------------------------
*outputting flag file
*-------------------------------------------------------------------------------
preserve
keep `occupation' core_`fixed_def'
save "tempFiles/core_jobs_flags", replace
label data "Generating using `do_location'"
restore

/*

*-------------------------------------------------------------------------------
*Question: what is the trajectory of the jobs in the intersection
*-------------------------------------------------------------------------------
use "tempFiles/borderJobClassificationLFS`educationType'", clear
keep 	year `occupation' jobType
duplicates drop

merge m:1 `occupation' using "tempFiles/definition_intersection_`chosen_def'", nogen
merge m:1 `occupation' using `new_core_flag', nogen
replace intersection_14=1 if !missing(intersection_14)
replace intersection_14=0 if missing(intersection_14)
g	 in_core=jobType==core_type

local log_name "output/intersection_new_jobs_14.txt"
log using `log_name', text replace
*Jobs that are in the intersection of transition / core
table `occupation' year if intersection_14, contents(mean in_core)

*Jobs added from core_16 to core_14
table `occupation' year if new_core, contents(mean in_core)
log close

