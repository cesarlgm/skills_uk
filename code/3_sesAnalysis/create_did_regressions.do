*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	regressions tables focussing on different measures of routine 
				pc use.
	
	output: 

*/
*===============================================================================
*===============================================================================
local occupation		`1'
local educationType		`2'
local aggregateSOC		`3'
local chosen_def		`4'
*===============================================================================
local do_location		"3\_sesAnalysis/create\_did\_regressions.do"

local switcher_flag		switcher`chosen_def'
local errors			vce(r)
local rankCap			5


use "./output/skillSESDatabase", clear
drop if missing(gwtall)

if `aggregateSOC'==1 {
	local occupation bsoc00Agg
}


if `educationType'==1{
	local education newEducation
	
}
else if `educationType'==2{
	local education alternativeEducation
	label define skillLabel 1 "\hspace{3mm}Below GCSE C" 2 "\hspace{3mm}GCSE C-A levels" ///
	3 "\hspace{3mm}Bachelor+"
	local baseLow	"Base level: Below GCSE C"
	local baseMid	"Base level: GCSE C-A levels"
}
else if `educationType'==3 {
	local education fourEducation
}


*I add the switching job flag
merge m:1 `occupation' using "tempFiles/transition_time_flags", nogen keep(3)

*I assign a shortened value label to education
local space 
label define	newEducationLbl 1 "`space'Low" 2 "`space'Mid" 3 "`space'High", modify

*This are the did flags
*------------------------------------------------------------------------------
g treat_first_out=		year>=first_out 	if `switcher_flag'
g treat_last_out=		year>=last_out  	if `switcher_flag'

g treat_first_in=		year>=first_in		if `switcher_flag'
g treat_last_in=		year>=last_in		if `switcher_flag'

local space 
label define treat_first_out 	0 "Baseline" 1 "`space'First out"
label define treat_last_out 	0 "Baseline" 1 "`space'Last out"
label define treat_first_in 	0 "Baseline" 1 "`space'First in"
label define treat_last_in 		0 "Baseline" 1 "`space'Last in"


*List of transition time definitions
local def_treat treat_first_out treat_last_out treat_first_in treat_last_in
foreach variable in `def_treat' {
	label values `variable' `variable'
}


*List of skill list definitions
local skill_list 		analyticalIndex 	manualIndex 	 	bmuseIndex
local filter_list		inlist(`education',1,2) inlist(`education',1,2) ///
						inlist(`education',2,3) inlist(`education',1,2) ///
						inlist(`education',2,3)


local def_counter=1
local transition_counter=1

levelsof 	restrictedType
local 		transition_list `r(levels)'

eststo clear
foreach transition in `transition_list' {
	local transition_filter: word `transition_counter' of `filter_list'
	foreach definition in `def_treat' {
		foreach skill in `skill_list' {
			*Occupation fe only
			qui unique `occupation' if restrictedType==`transition'&`transition_filter'
			local noccupations=`r(unique)'
			qui reghdfe `skill' ///
				i.`education'##i.`definition' if restrictedType==`transition'&`transition_filter', ///
				absorb(`occupation') `errors'
			
			qui estadd 	scalar occupations=`noccupations'
			eststo `skill'`def_counter'1`transition'
			
			*Occupation and year fe
			qui reghdfe `skill' ///
				i.`education'##i.`definition' if restrictedType==`transition'&`transition_filter', ///
				absorb(`occupation' i.year) `errors'
				
			qui estadd scalar occupations=`noccupations'
			eststo `skill'`def_counter'2`transition'
		}
		local ++def_counter
	}
	local ++transition_counter
}

estfe . *, labels( `occupation' "Occupation FE" year "Year FE")

*Starting outputting tables
*-------------------------------------------------------------------------------
local title_list `""Dependent variable: analytical skill""Dependent variable: manual skill""Dependent variable: routine skill""'
local table_options drop(_cons)  nobaselevels label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par star indicate(`r(indicate_fe)', labels("\checkmark" "")) ///
	stat(occupations N , label("\midrule Number of jobs" "Observations") fmt(%9.0fc)) 
local table_notes "robust standard errors in parenthesis. The dependent variable ranges from 0 to 1. Columns differ in the fixed effect included and the definition of the transition year. Regressions pool observations from all years, but use observations from transitioning occupations only. I restrict observations to the education levels indicated in the panel subtitle" 	
	
	
local counter=1
foreach skill in `skill_list' {
	local table_name "output/did_regression_`skill'.tex"
	local table_title: word `counter' of `title_list'
	
	textablehead using `table_name', ncols(8) title(`table_title') f(Regressor)
	
	writeln `table_name' "\textit{Low to Low-Mid} \\"
	esttab `skill'*112 using `table_name', `table_options'
	
	writeln `table_name' "\midrule\textit{Mid-High to High} \\"
	esttab `skill'*2303 using `table_name', `table_options'
	
	textablefoot using `table_name', notes(`table_notes') dofile(`do_location')
	local ++counter
}
