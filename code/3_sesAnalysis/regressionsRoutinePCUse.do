*==============================================================================
*Create skill regressions
*===============================================================================
*===============================================================================
local occupation		`1'
local educationType		`2'
local aggregateSOC		`3'
local regressionType	`4'
*===============================================================================
local do_location=		"3\_sesAnalysis/regressionsRoutinePCUse"

local obsMin			3
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
cap drop bmuse
cap drop bcuse
cap drop bouse
cap drop controutineuse
cap drop mouse


*I create two possible indexes
g pcuse=cusepc>=2
g imppcuse=cusepc>=3

g bcuse=		 		dusepc>=2
replace bcuse=0 		if cusepc==1

g bmuse=  				dusepc>=3
replace bmuse=0 		if cusepc==1

g bouse=			 	dusepc>=4
replace bouse=0 if 		cusepc==1


g 			controutineuse= 			(dusepc-1)/4
replace		controutineuse=0			if cusepc==1


g	graphLow=inlist(jobType, 1,2,12)&`education'==1
g	graphMid=inlist(jobType, 1,2,12)&`education'==2

g	graphMidH=inlist(jobType, 2,3,23)&`education'==2
g	graphHigh=inlist(jobType, 2,3,23)&`education'==3

g 	borderGraph12=inlist(jobType, 12)&inlist(`education',1,2)
g 	borderGraph23=inlist(jobType, 23)&inlist(`education',2,3)


*possible skill lists I use
local pcuseList 	pcuse  bouse bmuse bcuse controutineuse

levelsof jobType
local typeList `r(levels)'


*Creating regressions
foreach skill in `pcuseList' {
	foreach type in `typeList' {
		cap qui eststo `skill'`type': areg `skill' i.`education'  i.year  ///
			if jobType==`type', absorb(`occupation') vce(r)
			
		cap lincom 3.`education'-2.`education'
		local diff_t=r(estimate)/r(se)
		cap estadd scalar diff_t=`diff_t'
	}
}


*Creation of the tables
local coltitles=`""PC use""Basic""Mod-""Comp-""Cont""'

local tableTitle="Comparison of pc use measures"
local tableNote "robust standard errors in parenthesis. The regression includes data from occupations. I pool data from all years. Regressions include occupation and year fixed-effects"
local tableOptions drop(_cons *year)  nobaselevels  label append booktabs f collabels(none) ///
	nomtitles plain b(%9.2fc) se(%9.2fc) par star noobs stat(diff_t, ///
	label(`"\textit{t-statistic difference}"'))
local headline=" & & \multicolumn{4}{c}{\textbf{PC use complexity}} \\ \cline{3-6} "
	
local titleLabs `" "Below GCSE C" "GCSE C to A lev." "Bachelor+" "Below GCSE C/GCSE C to A lev. border" "Below GCSE C/Bachelor+ border" "GCSE C to A lev./Bachelor+ border" "'
		
label values `education' skillLabel
local counter=1

local tableName "./output/routinePCRegressions.tex"

textablehead using `tableName', ncols(5) coltitles(`coltitles') ///
	key(tab:skillRegs) col(c) title(`tableTitle') f(`baseLow') ///
	exhead(`headline')

writeln `tableName' "\textit{Mid-High jobs}\vspace{1mm} \\ "

esttab *use23 using `tableName',  `tableOptions'

writeln `tableName' "\midrule\textit{Low-Mid jobs}\vspace{1mm} \\ "
esttab *use12 using `tableName',  `tableOptions'

writeln `tableName' "\midrule\textit{Low jobs}\vspace{1mm} \\ "
esttab *use1 using `tableName',  `tableOptions'

writeln `tableName' "\midrule\textit{Mid jobs}\vspace{1mm} \\ "
esttab *use2 using `tableName',  `tableOptions'

writeln `tableName' "\midrule\textit{High jobs}\vspace{1mm} \\ "
esttab *use3 using `tableName',  `tableOptions'

textablefoot using `tableName', notes(`tableNote') dofile(`do_location')

