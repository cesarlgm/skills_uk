*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	creates graphs with number of jobs that are switching from year 
				to year
	
	output: 	 
	
	*Graphs and tables

				 
	*Labelling for other data
				

*/
*===============================================================================
local occupation  				`2'
local educationType  			`1'
local do_location 				"4\_lfsAnalysis/occ\_employment\_shares\_graphs.do"
local ses_years					2001 2006 2012 2017
local list_transition_jobs 		112 212 223 1202 2303
local graph_notes				"created with data from 2001-2017 UK LFS."

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


use "./tempFiles/lfsDatabaseRecodedEducation`educationType'", clear
keep if inrange(age,20,60)


merge m:1 `occupation' using "./tempFiles/occAvailabilityTable", nogen
drop withData*
drop if year<2001


egen year_people=sum(people), by(year)
egen educ_people=sum(people), by(year `education')
g educ_share_population=educ_people/year_people
drop educ_people	


merge m:1 `occupation' using "tempFiles/transition_time_flags", nogen
merge m:1 `occupation' using "tempFiles/core_jobs_flags", nogen

g		job_type_r=	core_16
replace job_type_r= restrictedType if missing(job_type_r)

drop switcher423-core_16

label define job_type_r 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid" 23 "Mid-high"

label values job_type_r job_type_r 

*In this part I select the appropriate set of education
*------------------------------------------------------------
g		in_graph=0
replace in_graph=1 if inlist(`education',1,2)&inlist(job_type_r, 112,212,1202)
replace in_graph=1 if inlist(`education',2,3)&inlist(job_type_r, 223,2303)


sort 	year `occupation' `education'
egen 	total_people=sum(people), by(year `occupation')
g 		occ_size=total_people/year_people
drop 	year_people
g 		educ_share= people/total_people

 qui foreach occ_type in `list_transition_jobs' {
	if  inlist(`occ_type', 112,212,1202) {
		local graph_type=1
	}
	else if inlist(`occ_type', 223,2303) {
		local graph_type=2
	}	
	
	qui levelsof 	`occupation' 		if job_type_r==`occ_type' 
	qui local 		occ_code_list_`occ_type'  `r(levels)'

	foreach occ_code in `occ_code_list_`occ_type'' {
		preserve
			local graph_title: label `occupation' `occ_code'
			keep if `occupation'==`occ_code'
			keep if in_graph
			
			grscheme, ncolor(5) style(tableau)


			sort year 

			*Creating the variables
			separate educ_share , by(`education') shortlabel
			local 	 occ_list `r(varlist)'

			separate educ_share_population,  by(`education') shortlabel
			local 	 ppl_list `r(varlist)'
			
			*Fixing the legend
			if `graph_type'==1 {
				local legend legend(order(1 "Below GCSE C (occ)" 2 "GCSE C to A lev. (occ)"  ///
				3 "Below GCSE C (population)" 4 "GCSE C to A lev. (population)"))
			}
			else if  `graph_type'==2 {
				local legend legend(order(1 "GCSE C to A lev. (occ)" 2 "Bachelor+ (occ)"  ///
				3 "GCSE C to A lev. (occ)" 4 "Bachelor+ (occ)"))
			}	
			
			local color_list blue red gs10 gs10
			tw line `occ_list' `ppl_list' year, recast(connected) lwidth(medthick) ///
				`legend' ytitle("Employment share") xline(`ses_years', lpatter(dot)) ///
				title("`graph_title'") lpattern(solid solid dash dash) ///
				lcolor(`color_list') mcolor(`color_list') yscale(range(0 .8)) ///
				ylabel(0(.1).8)
			
			graph export "output/occ_transitions_`occ_code'_`occ_type'.pdf", replace
		restore
	}
}	


*Outputting latex graphs

*Mid-high to high jobs
foreach occ_code in `occ_code_list_2303' {
	local graph_list `graph_list' occ_transitions_`occ_code'_2303
}
latexfigure using "output/occ_transitions_2303.tex", rowsize(2) path(../output) ///
	figurelist( `graph_list') title("Mid-High to High transitions")

	
*Mid-high to high jobs
forvalues count=1/2 {
	forvalues occ_count=1/12 {
		gettoken occ_code occ_code_list_112: occ_code_list_112
		if "`occ_code'"!=""{
			local graph_list_`count' `graph_list_`count'' occ_transitions_`occ_code'_112
		}
	}
}

latexfigure using "output/occ_transitions_112_1.tex", rowsize(3) path(../output) ///
	figurelist( `graph_list_1') title("Low to Low-Mid transitions") ///
	note(`graph_notes') dofile(`do_location')
latexfigure using "output/occ_transitions_112_2.tex", rowsize(3) path(../output) ///
	figurelist( `graph_list_2') title("Low to Low-Mid transitions") cont ///
	note(`graph_notes') dofile(`do_location')
latexfigure using "output/occ_transitions_112_2.tex", rowsize(3) path(../output) ///
	figurelist( `graph_list_2') title("Low to Low-Mid transitions") cont ///
	note(`graph_notes') dofile(`do_location')

	
latexfigure using "output/occ_transitions_212.tex", path(../output) ///
	figurelist( occ_transitions_5312_212) title("Mid to Low-Mid transitions") cont ///
	note(`graph_notes') dofile(`do_location')

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Aggregate level graph
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

use "./tempFiles/lfsDatabaseRecodedEducation`educationType'", clear
keep if inrange(age,20,60)


merge m:1 `occupation' using "./tempFiles/occAvailabilityTable", nogen
drop withData*
drop if year<2001


merge m:1 `occupation' using "tempFiles/transition_time_flags", nogen
merge m:1 `occupation' using "tempFiles/core_jobs_flags", nogen

g		job_type_r=	core_16
replace job_type_r= restrictedType if missing(job_type_r)

drop switcher423-core_16

label define job_type_r 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid" 23 "Mid-high"

label values job_type_r job_type_r 

collapse (sum) people, by(job_type_r `education' year)  

egen year_people=sum(people), by(year)
egen educ_people=sum(people), by(year `education')
g educ_share_population=educ_people/year_people
drop educ_people	

*In this part I select the appropriate set of education
*------------------------------------------------------------
g		in_graph=0
replace in_graph=1 if inlist(`education',1,2)&inlist(job_type_r, 112,212,1202)
replace in_graph=1 if inlist(`education',2,3)&inlist(job_type_r, 223,2303)

sort 	year job_type_r `education'
egen 	total_people=sum(people), by(year job_type_r)
g 		occ_size=total_people/year_people
drop 	year_people
g 		educ_share= people/total_people

*Creating the variables
separate educ_share , by(`education') shortlabel
local 	 occ_list `r(varlist)'

separate educ_share_population,  by(`education') shortlabel
local 	 ppl_list `r(varlist)'


local legend legend(order(1 "Below GCSE C (occ)" 2 "GCSE C to A lev. (occ)"  ///
3 "Below GCSE C (population)" 4 "GCSE C to A lev. (population)"))

grscheme, ncolor(5) style(tableau)

local color_list blue red gs10 gs10
tw line educ_share1 educ_share2 educ_share_population1 educ_share_population2 ///
	year if job_type_r==112, recast(connected) lwidth(medthick) ///
	`legend' ytitle("Employment share") xline(`ses_years', lpatter(dot)) ///
	title("`graph_title'") lpattern(solid solid dash dash) ///
	lcolor(`color_list') mcolor(`color_list') yscale(range(0 .8)) ///
	ylabel(0(.1).8)
graph export "output/occ_transitions_1202.pdf", replace

grscheme, ncolor(5) style(tableau)

local legend legend(order(1 "GCSE C to A lev. (occ)" 2 "Bachelor+ (occ)"  ///
3 "GCSE C to A lev. (occ)" 4 "Bachelor+ (occ)"))

tw line educ_share2 educ_share3 educ_share_population2 educ_share_population3 ///
	year if job_type_r==2303, recast(connected) lwidth(medthick) ///
	`legend' ytitle("Employment share") xline(`ses_years', lpatter(dot)) ///
	title("`graph_title'") lpattern(solid solid dash dash) ///
	lcolor(`color_list') mcolor(`color_list') yscale(range(0 .8)) ///
	ylabel(0(.1).8) 
graph export "output/occ_transitions_2303.pdf", replace

local figlabs `""Low to Low-Mid""Mid-High to High""'
latexfigure using "output/occ_transitions_aggregated.tex", rowsize(1) path(../output) ///
	figurelist( occ_transitions_1202 occ_transitions_2303) ///
	title("Aggregated graphs") figlab(`figlabs') note(`graph_notes') dofile(`do_location')
