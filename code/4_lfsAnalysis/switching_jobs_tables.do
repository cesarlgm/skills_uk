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

*===============================================================================
*QUESTION: 	I WANT TO ANSWER HERE: WHAT IS THE TRADE-OFF WE HAVE WHEN WE BECOME 
*		 	MORE FLEXIBLE
*===============================================================================

*ALLOWING THE NUMBER OF SWITCHES TO VARY
*--------------------------------------------------------------------------
egen nSwitches=sum(differentCategory), by(`occupation')

preserve 
local length_list 		6 8 8 8 10 10 10
local init_list			3 4 3 5 5  4  6
local switch_list		1 3 3 3 7  7  7
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


label define restrictedType 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid"

label values restrictedType restrictedType 


collapse (sum) switcher* if year==2001, by(restrictedType)
egen 	nonEmpty=rowtotal(switcher*)
keep	if nonEmpty>0

local table_name 	"output/relaxing_number_switches.tex"
local table_title 	"Effect of relaxing number of switches constraint" 
local col_titles	`""3-3-1""4-4-3""3-5-3""5-3-3""5-5-7""4-6-7""6-4-7""'
local table_note	"each column shows the breakdown by transition type when my definition of a transitioning job is the union all the current and previous columns. For example in column two I define a transition job as the union of 3-3-1 and 4-4-3"
local stat 			sum

textablehead using `table_name', ncols(7) title(`table_title') ///
	coltitles(`col_titles') sup("Definition") f("Transition type") 

tabout restrictedType using `table_name', cells( ///
	`stat' switcher331 `stat' switcher443 `stat' switcher353 ///
	`stat' switcher533 `stat' switcher557 `stat' switcher467 ///
	`stat' switcher647) style(tex) sum ///
	append h1(nil) h2(nil) h3(nil) format(0) bt
	
textablefoot using `table_name', notes(`table_note')

restore


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


label define restrictedType 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid"

label values restrictedType restrictedType 

preserve

collapse (sum) switcher* if year==2001, by(restrictedType)
egen 	nonEmpty=rowtotal(switcher*)
keep	if nonEmpty>0

local table_name 	"output/relaxing_number_switches_alternative.tex"
local table_title 	"Effect of relaxing number of switches constraint" 
local col_titles	`""3-3-3""2-4-3""4-2-3""5-5-7""4-6-7""6-4-7""'
local table_note	"each column shows the breakdown by transition type when my definition of a transitioning job is the union all the current and previous columns"
local stat 			sum

textablehead using `table_name', ncols(6) title(`table_title') ///
	coltitles(`col_titles') sup("Definition") f("Transition type") 

tabout restrictedType using `table_name', cells( ///
	`stat' switcher333 `stat' switcher243 `stat' switcher423 ///
	`stat' switcher557 `stat' switcher467 `stat' switcher647) style(tex) sum ///
	append h1(nil) h2(nil) h3(nil) format(0) bt
	
textablefoot using `table_name', notes(`table_note')
restore
