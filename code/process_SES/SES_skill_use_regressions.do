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

global education educ_3_mid

use "data/temporary/filtered_dems_SES", clear
drop if missing(gwtall)

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

rename $education education
rename bsoc00Agg occupation


do "code/process_SES/compute_skill_indexes.do"


eststo clear
foreach index in $index_list {
	eststo `index'r: reghdfe `index' i.education, absorb(year) vce(cl occupation)
	eststo `index'n: reghdfe `index' i.education, absorb(year occupation) vce(cl occupation)
}


esttab *r 
esttab *n

label define education 1 "HS dropouts" 2 "HG graduates" 3 "College+"
label values education education

local table_name "results/tables/skill_use_within_jobs.tex"
local table_title "Within-job skill use across education groups"
local coltitles `""Manual""Routine""Abstract""Social""'
local table_notes "standard errors clustered at the occupation level in parenthesis"

textablehead using `table_name', ncols(4) coltitles(`coltitles') title(`table_title')
leanesttab *n using `table_name', fmt(3) append star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") nobase stat(N, label( "\midrule Observations") fmt(%9.0fc))
texspec using `table_name', spec(y y y y) label(Occupation f.e.)
texspec using `table_name', spec(y y y y) label(Year f.e.)
textablefoot using `table_name', notes(`table_notes')



/*

OLD TABLES


local do_location		"3\_sesAnalysis/createSESSkillRegressions.do"
local definition_list educ_3_low educ_3_mid
local index_list 	abstract social routine manual

use "data/additional_processing/SES_skill_index_database", clear
drop if missing(gwtall)

cap drop temp

eststo clear


foreach definition in `definition_list' { 
	merge m:1 year bsoc00Agg using  "data/temporary/job_classification_`definition'", ///
		keep(3) keepusing(ref_job_type0) nogen
	tab ref_job_type0

	foreach index in `index_list' {
		eststo `index'_`definition'12: reghdfe `index' i.`definition' if inlist(`definition',1,2)&ref_job_type0==12,	///
		 	absorb(i.bsoc00Agg) vce(r)

		unique bsoc00Agg if ref_job_type0==12
		
		estadd scalar n_occ=`r(unique)'

		eststo `index'_`definition'23: reghdfe `index' i.`definition' if inlist(`definition',2,3)&ref_job_type0==23,	///
		 	absorb(i.bsoc00Agg) vce(r)

		unique bsoc00Agg if ref_job_type0==23

		estadd scalar n_occ=`r(unique)'

		eststo `index'_`definition'12_y: reghdfe `index' i.`definition' if inlist(`definition',1,2)&ref_job_type0==12,	///
		 	absorb(i.bsoc00Agg i.year) vce(r)

		unique bsoc00Agg if ref_job_type0==12

		estadd scalar n_occ=`r(unique)'

		eststo `index'_`definition'23_y: reghdfe `index' i.`definition' if inlist(`definition',2,3)&ref_job_type0==23,	///
		 	absorb(i.bsoc00Agg i.year) vce(r)

		unique bsoc00Agg if ref_job_type0==23

		estadd scalar n_occ=`r(unique)'


		local table_name "results/tables/skill_use_border_jobs_`definition'.tex"
		local coltitles Analytical Social Routine Manual Analytical Social Routine Manual
		local table_title "Skill use in border jobs"
		local table_options  stats(n_occ r2 N,label("\midrule Number of occ." "Overall $ R^2$" "Observations") fmt(%9.0fc %9.2fc %9.0fc)) ///
			nobase se  label   f collabels(none) ///
			nomtitles plain b(%9.3fc) se(%9.3fc) par star  keep(*`definition')
		writeln `table_name' "\midrule \textit{Low-Mid jobs} \\"


		textablehead using `table_name', ncols(8) coltitles(`coltitles') ///
			key(tab:skillRegs) col(c) title(`table_title') land
		
		estfe . *, labels(bsoc00Agg "Occupation FE" year "Year FE")

		esttab *_`definition'12 *_`definition'12_y using `table_name', `table_options' append ///
			indicate(`r(indicate_fe)')

		writeln `table_name' "\midrule \textit{Mid-High jobs} \\"

		
		estfe . *, labels(bsoc00Agg "Occupation FE" year "Year FE")
		esttab *_`definition'23 *_`definition'23_y using `table_name', `table_options' append ///
			indicate(`r(indicate_fe)')

		textablefoot using `table_name', land
		
	}
}




/*
*Creating regressions
foreach skill in `averageList' `restrictedList' `orthogonalList' `averageListSd' {
	*First I compute the standard deviation
	preserve
		collapse (mean) `skill' (count) observations=year, by(`occupation')
		summ `skill' [aw=observations]		
		local occ_sd=`r(sd)'
	restore
	
	foreach type in `typeList' {
		cap qui eststo `skill'`type': areg `skill' i.`education'  i.year  ///
			if jobType==`type'`filter`type'', absorb(`occupation') vce(r)
			

		*Standardizing the coefficient
		*Firt I get the maximum education
		summ `education' if jobType==`type'`filter`type''
		local max_education=`r(max)'
		
		
		local standard=_b[`max_education'.`education']/ `occ_sd'
		cap estadd scalar occ_sd= `occ_sd'
		cap estadd scalar standard= `standard'
		cap qui eststo `skill'`type'
	}
}

*Creation of the tables
local coltitles=`""Analytical""Manual""Routine""'

local tableTitle "Relative skill use in border jobs across education groups (simple average indexes)"
local tableNote "all skill indexes range between 0 and 1. Regressions use individual-level data. Robust standard errors in parenthesis. Coefficents represent the difference relative the lower education level. I use dummy of basic to moderate PC use complexity as measure of routineness. I pool data from all years. Regressions include occupation fixed-effects. Effect sizes are computed as the regression coefficient divided by the standard deviation in the occupation-level skill indexes"
local tableOptions drop(_cons *year)  nobaselevels label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par star  ///
		stats( standard r2 N, ///
		label( "\hspace{3mm}Effect size" "\midrule Overall $ R^2$" "Observations") ///
		fmt(%9.3fc %9.2fc %9.2fc %9.0fc))

local titleLabs `""Below GCSE C / GCSE C-A lev. border" "GCSE C to A lev. / Bachelor+ border""'
local subtitleLabs `""Below GCSE C" "GCSE C to A lev.""'
		
label values `education' skillLabel
local counter=1

local tableName "./output/skillRegressionsTable`educationType'`regressionType'.tex"
textablehead using `tableName', ncols(3) coltitles(`coltitles') ///
	key(tab:skillRegs) col(c) title(`tableTitle') 

foreach type in 12 23 {
	if `counter'>1 {
		local midrule \midrule
	}
	local titleLab: word `counter' of `titleLabs'
	local subtitleLab: word `counter' of `subtitleLabs'
	local ++counter
	writeln `tableName' "`midrule'\textit{`titleLab'}\vspace{1mm} \\ "
	*writeln `tableName' "\hspace{3mm}\textbf{Base level: }`subtitleLab' \\ "
	esttab *Index`type' using `tableName',  `tableOptions'
}
textablefoot using `tableName', notes(`tableNote') dofile(`do_location')


*Creation of the tables
local coltitles=`""Analytical""Manual""Routine""'

local tableTitle "Relative skill use in border jobs across education groups (index with standardized variables)"
local tableNote "all skill indexes range between 0 and 1. Regressions use individual-level data. Robust standard errors in parenthesis. Coefficents represent the difference relative the lower education level. I use dummy of basic to moderate PC use complexity as measure of routineness. I pool data from all years. Regressions include occupation fixed-effects. Effect sizes are computed as the regression coefficient divided by the standard deviation in the occupation-level skill indexes"
local tableOptions drop(_cons *year)  nobaselevels label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par star  ///
		stats( standard r2 N, ///
		label( "\hspace{3mm}Effect size" "\midrule Overall $ R^2$" "Observations") ///
		fmt(%9.3fc %9.2fc %9.2fc %9.0fc))

local titleLabs `""Below GCSE C / GCSE C-A lev. border" "GCSE C to A lev. / Bachelor+ border""'
local subtitleLabs `""Below GCSE C" "GCSE C to A lev.""'
		
label values `education' skillLabel
local counter=1

local tableName "./output/skillRegressionsTable`educationType'`regressionType'Standardized.tex"
textablehead using `tableName', ncols(3) coltitles(`coltitles') ///
	key(tab:skillRegs) col(c) title(`tableTitle') 

foreach type in 12 23 {
	if `counter'>1 {
		local midrule \midrule
	}
	local titleLab: word `counter' of `titleLabs'
	local subtitleLab: word `counter' of `subtitleLabs'
	local ++counter
	writeln `tableName' "`midrule'\textit{`titleLab'}\vspace{1mm} \\ "
	*writeln `tableName' "\hspace{3mm}\textbf{Base level: }`subtitleLab' \\ "
	esttab *Index_sd`type' using `tableName',  `tableOptions'
}
textablefoot using `tableName', notes(`tableNote') dofile(`do_location')
