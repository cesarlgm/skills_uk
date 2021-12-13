*===============================================================================
*CREATE TABLE WITH AVERAGE USE OF SES SKILLS BY EDUCATION LEVEL
*===============================================================================

*Author: César Garro-Marín

*===============================================================================
local occupation		`1'
local educationType		`2'
local aggregateSOC		`3'
local weight			`4'
*===============================================================================
local do_location="3\_sesAnalysis/create\_average\_use\_table.do"

local obsMin			3
local errors			vce(r)
local rankCap			5
local hspace			\hspace{3mm}

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

if `weight'==1 {
	local reg_weight 	[pw=gwtall]
	local weight_note 	Means \textbf{weighted} by SES sampling weights
}
else {
	local reg_weight
	local weight_note 	Means are \textbf{unweighted}
}

*Adding job type flsgs
merge m:1 `occupation' using "tempFiles/transition_time_flags", nogen keep(3) ///
	keepusing(restrictedType)
	
merge m:1 `occupation' using "tempFiles/core_jobs_flags", nogen


g		job_type_r	= restrictedType
replace job_type_r	= core_16 if missing(job_type_r)

local space \hspace{3mm}
label define job_type_r 1 "`space'Low" 2 "`space'Mid" 3 "`space'High" 12 "`space'Low-mid" ///
	112 "`space'Low to Low-Mid" 212 "`space'Mid to Low-Mid" 223 "`space'Mid to Mid-High" ///
	1202 "`space'Low-Mid to Mid" 2303 "`space'Mid-High to High" 323 "`space'High to Mid-High" ///
	1201 "`space'Low-Mid to Low" 2302 "`space'Mid-High to Mid" 23 "`space'Mid-High"
	
label values job_type_r job_type_r

*possible skill lists I use
local average_list 		analyticalIndex 	manualIndex 	bmuseIndex


levelsof 	job_type_r
local 		type_list 	`r(levels)'
levelsof 	`education'
local		educ_list	`r(levels)'

eststo clear
qui{
	foreach job_type in `type_list' {
		foreach educ_level in `educ_list' {
			foreach skill in `average_list' {
				 cap eststo `skill'`educ_level'`job_type': reg `skill' if job_type_r==`job_type'&`education'==`educ_level' `reg_weight'
			}
		}
	}
}


*-------------------------------------------------------------------------------
*Core vs border jobs
*-------------------------------------------------------------------------------

*Fix this part
local table_title "Average skill use in core vs border jobs"
local table_name "output/average_core_border_`weight'.tex"
local col_titles `""Analytical""Manual""Routine""'
local table_notes "the table shows average skill use by job type. `weight_note'"
local table_options    label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par noobs

textablehead using `table_name', ncols(3) f(Job type) title(`table_title') ///
	coltitles(`col_titles') drop

*Low education
writeln `table_name' "\textit{Low-education individuals} \\  \midrule"
local educ 1
esttab *Index`educ'1 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low jobs")
esttab *Index`educ'12 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low-mid jobs")
esttab *Index`educ'2 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Mid jobs")
*Mid education
writeln `table_name' "\textit{Mid-education individuals} \\  \midrule"
local educ 2
esttab *Index`educ'1 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low jobs")
esttab *Index`educ'12 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low-mid jobs")
esttab *Index`educ'2 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Mid jobs")
textablefoot using `table_name', notes(`table_notes') dofile(`do_location')


*-------------------------------------------------------------------------------
*Core vs transitioning jobs
*-------------------------------------------------------------------------------
local table_title "Average skill use in core vs transitioning jobs"
local table_name "output/average_core_transitioning_`weight'.tex"
local col_titles `""Analytical""Manual""Routine""'
local table_options    label append booktabs f collabels(none) ///
	nomtitles plain b(%9.3fc) se(%9.3fc) par noobs

textablehead using `table_name', ncols(3) f(Job type) title(`table_title') ///
	coltitles(`col_titles') drop

*Low education
local jobType=1
writeln `table_name' "\textit{Low-education individuals} \\  \midrule"

local educ 1

esttab *Index`educ'1 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low jobs")
esttab *Index`educ'112 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low to Low-Mid jobs")
esttab *Index`educ'12 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low-Mid jobs")
*Mid education
writeln `table_name' "\textit{Mid-education individuals} \\  \midrule"

local educ 2

esttab *Index`educ'1 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low jobs")
esttab *Index`educ'112 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low to Low-Mid  jobs")
esttab *Index`educ'12 	using `table_name',  `table_options' coeflabel(_cons "`hspace'Low-Mid jobs")
textablefoot using `table_name', notes(`table_notes') dofile(`do_location')



/*


local tableNote "for the measure of routine computer use, I assign the lowest value possible to people who do not use a computer."
local tableName "./output/educationJobTypeAverages.tex"
local tableTitle "Education level averages by job type (skill index averages)"
local extraCode	"& & & &\multicolumn{2}{c}{\textbf{Dummy}}&\multicolumn{2}{c}{\textbf{Continuous}} \\ \cline{5-6} \cline{7-8}"
local tableOptions f plain append collabels(none) nomtitles noobs b(%9.1fc) not
local coltitles `""Analytical""Manual""Routine""PC use""Rout. PC""PC use""Rout. PC""'
textablehead using `tableName', ncols(7) coltitles(`coltitles') ///
		key(tab:skillMeans) col(c) title(`tableTitle') exhead(`extraCode')

writeln `tableName' " \textit{Below GCSE C jobs}\\ \midrule "
local jobType=1
esttab *Index1`jobType'	 using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Below GCSE C")
esttab *Index2`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'GCSE C-A levels")
esttab *Index3`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Bachelor+")


writeln `tableName' "\midrule \textit{GCSE C-A levels jobs}\\   \midrule"
local jobType=2
esttab *Index1`jobType'	 using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Below GCSE C")
esttab *Index2`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'GCSE C-A levels")
esttab *Index3`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Bachelor+")


writeln `tableName' "\midrule \textit{Bachelor +}\vspace{1mm} \\  \midrule "
local jobType=3
esttab *Index1`jobType'	 using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Below GCSE C")
esttab *Index2`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'GCSE C-A levels")
esttab *Index3`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Bachelor+")

writeln `tableName' "\midrule \textit{Below GCSE C / GCSE C-A levels jobs}\\  \midrule "
local jobType=12
esttab *Index1`jobType'	 using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Below GCSE C")
esttab *Index2`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'GCSE C-A levels")
esttab *Index3`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Bachelor+")


writeln `tableName' "\midrule \textit{GCSE C-A levels / Bachelor+ jobs}\\  \midrule"
local jobType=23
esttab *Index1`jobType'	 using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Below GCSE C")
esttab *Index2`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'GCSE C-A levels")
esttab *Index3`jobType' using `tableName',  `tableOptions' coeflabel(_cons "`hspace'Bachelor+")


textablefoot using `tableName', notes(`tableNote') dofile(`do_location')
