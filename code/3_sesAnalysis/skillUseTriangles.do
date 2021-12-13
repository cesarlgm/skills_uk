*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	outputs data I use in R to create the skill use triangles
	
	output: 	tempFiles/skillSESdatabaseAggTimeSplit.csv

*/
*===============================================================================

local occupation 		`1'
local filter 			`2'
local obsThreshold		`3'
local aggregateSOC		`4'
local educationType		`5'
local yearList 2001 2006 2012 2017
local do_location 		"3\_sesAnalysis/skillUseTriangles.do"	

if `educationType'==1 {
	local education newEducation
}
else if `educationType'==2 {
	local education alternativeEducation
}
else if `educationType'==3 {
	local education fourEducation
}

if `aggregateSOC'==1 {
	local occupation bsoc00Agg
}

use "./output/skillSESDatabase", clear

cap drop 		observationsLFS
rename obsTotal observationsLFS

merge m:1 `occupation' using "tempFiles/transition_time_flags", nogen keep(3) ///
	keepusing(restrictedType)
	
merge m:1 `occupation' using "tempFiles/core_jobs_flags", nogen

g		job_type_r	= restrictedType
replace job_type_r	= core_16 if missing(job_type_r)

*-------------------------------------------------------------------------------
*Labelling the job types
*-------------------------------------------------------------------------------
label define job_type_r 1 "Low" 2 "Mid" 3 "High" 12 "Low-mid" ///
	112 "Low to Low-Mid" 212 "Mid to Low-Mid" 223 "Mid to Mid-High" ///
	1202 "Low-Mid to Mid" 2303 "Mid-High to High" 323 "High to Mid-High" ///
	1201 "Low-Mid to Low" 2302 "Mid-High to Mid" 23 "Mid-High"

label values job_type_r job_type_r 

drop restrictedType core_16
	
	
*-------------------------------------------------------------------------------
*Graph type indicators
*-------------------------------------------------------------------------------
g	graphLow=inlist(jobType, 1,2,12)&`education'==1
g	graphMid=inlist(jobType, 1,2,12)&`education'==2

g	graphMidH=inlist(jobType, 2,3,23)&`education'==2
g	graphHigh=inlist(jobType, 2,3,23)&`education'==3

g 	borderGraph12=inlist(jobType, 12)&inlist(`education',1,2)
g 	borderGraph23=inlist(jobType, 23)&inlist(`education',2,3)

g	graphSep=jobType==`education'


*creating two routine pc use indicators
g		routinePC=dusepc>3
replace routinePC=0 if missing(dusepc)

g 		contRoutinePC=dusepc
replace	contRoutinePC=1 if dusepc==.a

g		moderatePC=inrange(dusepc,3,4)
replace	moderatePC=0 if dusepc==.a

foreach variable in routinePC contRoutinePC moderatePC {
	g `variable'Index=`variable'
	g `variable'Ort=`variable'
	g `variable'Factor=`variable'
}


*I normalize the indexes from 0 to 1
ds *Factor *Ort *Index  routinePC contRoutinePC moderatePC
foreach variable in `r(varlist)' {
	xtile temp=`variable', nq(100)
	replace `variable'=temp
	drop temp
}

**

*Index with dummy
local indexListDum 		analyticalIndex 	manualIndex 		routinePCIndex
local factorListDum 	analyticalFactor 	manualFactor 		routinePCFactor
local ortListDum 		analyticalOrt 		manualOrt			routinePCOrt

*Index with continuous measure
local indexListCont 	analyticalIndex 	manualIndex 		contRoutinePCIndex
local factorListCont 	analyticalFactor 	manualFactor 		contRoutinePCFactor
local ortListCont 		analyticalOrt 		manualOrt 			contRoutinePCOrt

*Index with moderate PC dummy
local indexListMod 		analyticalIndex 	manualIndex 		moderatePCIndex
local factorListMod 	analyticalFactor 	manualFactor 		moderatePCFactor
local ortListMod 		analyticalOrt 		manualOrt 			moderatePCOrt

foreach index in indexList factorList ortList {
	*Indexes with dummy
	egen tempTotal`index'=rowtotal(``index'Dum')
	foreach variable in ``index'Dum' {
		g `variable'Dum=`variable'/tempTotal`index'*100
	}
	drop temp*
	
	*Continuous measure
	egen tempTotal`index'=rowtotal(``index'Cont')
	foreach variable in ``index'Cont' {
		g `variable'Cont=`variable'/tempTotal`index'*100
	}
	drop temp*
	
	*Moderate dummy
	egen tempTotal`index'=rowtotal(``index'Mod')
	foreach variable in ``index'Mod' {
		g `variable'Mod=`variable'/tempTotal`index'*100
	}
	drop temp*
}

*Variable list individual data graphs
local indivList year `occupation' `education' jobType ///
	analyticalIndexDum-moderatePCOrtMod graph* 

preserve
keep `indivList'
export delimited "tempFiles/skillSESdatabase.csv", replace nolabel
restore

ds *Dum *Cont *Mod 


preserve
drop if missing(year)

collapse (mean) `r(varlist)' (mean) graph* border* (count) observationsSES=year ///
	(mean) year=year weight* observationsLFS, ///
	by(`education' `occupation' jobType)

g weight_LFS_SES1=weight1*sqrt(observationsLFS*observationsSES)
g weight_LFS_SES2=weight2*sqrt(observationsLFS*observationsSES)

g weight_obs_LFS1=weight1*observationsLFS
g weight_obs_LFS2=weight2*observationsLFS

g weight_obs_SES1=weight1*observationsSES
g weight_obs_SES2=weight2*observationsSES

egen occObs=sum(observationsSES), by(`occupation' jobType)

g	 toLabel=0
replace toLabel=1 if `occupation'==3231&jobType==3&`education'==3
replace toLabel=1 if `occupation'==5241&jobType==2&`education'==2
replace toLabel=1 if `occupation'==9233&jobType==1&`education'==1

cap drop pcInt* pcComp*

drop if missing(year)

export delimited "tempFiles/skillSESdatabaseAgg.csv", replace nolabel
restore 

*-------------------------------------------------------------------------------
*OUTPUTTING LATEX GRAPHS
*-------------------------------------------------------------------------------

*Comparing different measures of routine use
*===============================================================================
local figureLabs=`""Routine PC dummy""Routine PC continuous""Moderate PC use dummy""'
local title="Comparison of routine measures"
latexfigure using "output/triangleRoutineComparison.tex", path(../output) ///
	figurelist( densitySepDensityDum ///
	densitySepDensityCont densitySepDensityDum) ///
	figlab(`figureLabs') title(`title') ///
	rowsize(2)
	
local title="Comparison of routine measures (scatterplots)"
latexfigure using "output/triangleRoutineComparisonScatter.tex", path(../output) ///
	figurelist( densitySepScatterDum ///
	densitySepScatterCont densitySepScatterMod) ///
	figlab(`figureLabs') title(`title') ///
	rowsize(2)

*Graphs exploring the weighting schemes
*===============================================================================		
local title="Exploring weighting schemes (density plots)"
local figure_note= "figure based on occupation-level averages."
local figureLabs=`""Observations in SES education-occupation-job type cell""$ \sqrt{d_1d_2}\times observations_{LFS} $""$ \sqrt{d_1d_2\times observations_{LFS} \times observations_{SES}} $""$ \sqrt{d_1d_2}\times observations_{SES} $""'
latexfigure using "output/weightedTriangles.tex", path(../output) ///
	figurelist( densitySepDensityDum ///
	densitySepDensityDumLFS1 densitySepDensityDumSES1 densitySepDensityDumdistSES1 ) ///
	figlab(`figureLabs') title(`title') rowsize(2) note(`figure_note') ///
	dofile(`do_location')

local title="Exploring weighting schemes (scatterplots)"
latexfigure using "output/weightedTrianglesScatter.tex", path(../output) ///
	figurelist( densitySepScatterDum ///
	densitySepScatterDumLFS1 densitySepScatterDumSES1 densitySepScatterDumdistSES1 ) ///
	figlab(`figureLabs') title(`title') rowsize(2) note(`figure_note') ///
	dofile(`do_location')


local title="Exploring weighting: time change density plots"
latexfigure using "output/weightedTrianglesTimeDensity.tex", path(../output) ///
	figurelist( densitySepTimeDum ///
	densitySepTimeDumLFS1 densitySepTimeDumSES1 ) ///
	figlab(`figureLabs') title(`title') rowsize(1) note(`figure_note') ///
	dofile(`do_location')

*===============================================================================
*OUTPUTTING DATASET FOR RESTRICTED TYPE TRIANGLE GRAPHS
*===============================================================================

drop if missing(year)
ds *Dum *Cont *Mod 

collapse (mean) `r(varlist)' (mean) graph* border* (count) observationsSES=year ///
	(mean) year=year weight* observationsLFS, ///
	by(`education' `occupation' job_type_r)

g weight_LFS_SES1=weight1*sqrt(observationsLFS*observationsSES)
g weight_LFS_SES2=weight2*sqrt(observationsLFS*observationsSES)

g weight_obs_LFS1=weight1*observationsLFS
g weight_obs_LFS2=weight2*observationsLFS

g weight_obs_SES1=weight1*observationsSES
g weight_obs_SES2=weight2*observationsSES


*Creating indicators for graphs with restricted job types
*-------------------------------------------------------------------------------
g	grLM_border_l=inlist(job_type_r,1,2,12)&inlist(`education',1)
g	grLM_border_m=inlist(job_type_r,1,2,12)&inlist(`education',2)
g	grMH_border_m=inlist(job_type_r,2,3,23)&inlist(`education',2)
g	grMH_border_h=inlist(job_type_r,2,3,23)&inlist(`education',3)



g	grLM_trans_l=inlist(job_type_r,1,2,112)&inlist(`education',1)
g	grLM_trans_m=inlist(job_type_r,1,2,112)&inlist(`education',2)
g	grMH_trans_l=inlist(job_type_r,2,3,2303)&inlist(`education',2)
g	grMH_trans_m=inlist(job_type_r,2,3,2303)&inlist(`education',3)


export delimited "tempFiles/skillSESdatabaseAgg_restricted.csv", replace nolabel

local title=		"Comparing core vs border jobs"
local figure_notes=	"graphs show occupation level averages. Observations weighted using $ \sqrt{d_1d_2  \times  observations_{LFS} \times  observations_{SES} }$"

local figureLabs=`""Low individuals""Mid individuals""Mid individuals""High individuals""'
latexfigure using "output/restricted_LM_border.tex", path(../output) ///
	figurelist( restricted_grLM_border_l restricted_grLM_border_m ///
	restricted_grMH_border_m restricted_grMH_border_h) ///
	figlab(`figureLabs') title(`title') rowsize(2) note(`figure_notes') ///
	dofile(`do_location')

	
local title="Comparing core vs transitioning jobs"
local figureLabs=`""Low individuals""Mid individuals""Mid individuals""High individuals""'
latexfigure using "output/restricted_LM_trans.tex", path(../output) ///
	figurelist( restricted_grLM_trans_l restricted_grLM_trans_m ///
	restricted_grMH_trans_m	restricted_grMH_trans_h) ///
	figlab(`figureLabs') title(`title') rowsize(2) note(`figure_notes') ///
	dofile(`do_location')
	
/*
*Comparing switching jobs / fixed jobs
*===============================================================================
local title="Limiting to jobs that stay in the same type (density plots)"
local figureLabs=`""Observations in SES education-occupation-job type cell""$ \sqrt{d_1d_2}\times observations_{LFS} $""$ \sqrt{d_1d_2}\times observations_{LFS} \times observations_{SES} $""$ \sqrt{d_1d_2}\times observations_{SES} $""'
latexfigure using "output/weightedTrianglesFixed.tex", path(../output) ///
	figurelist( densitySepDensityDumFixed ///
	densitySepDensityDumLFS1Fixed densitySepDensityDumSES1Fixed  ///
	densitySepDensityDumdistSES1Fixed ) ///
	figlab(`figureLabs') title(`title') rowsize(2)

local title="Limiting to jobs that stay in the same type (scatterplots)"
latexfigure using "output/weightedTrianglesScatterFixed.tex", path(../output) ///
	figurelist( densitySepScatterDumFixed ///
	densitySepScatterDumLFS1Fixed densitySepScatterDumSES1Fixed ///
	densitySepScatterDumdistSES1Fixed ) ///
	figlab(`figureLabs') title(`title') rowsize(2)
