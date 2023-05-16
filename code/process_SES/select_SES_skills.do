*===============================================================================
*CREATE SES SKILLS
*===============================================================================

/*
*Performs
	- Factor analysis
	- Creates factors and selects some variables
*/
*===============================================================================


local occupation 		`1'
local do_location=		"2\_process_SES/select\_SES\_skills.do"
set graphics on 


use "data/temporary/filtered_dems_SES", clear

do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

cap log close
log using "results/log_files/n_observations_year.txt", replace
table year
log close



*===============================================================================
*ORDERING THE DATASET A BIT
*===============================================================================
order 	year crosspid emptype edlev sex age bsoc2000 bsoc2010 ///
		isco88 b_soc90 bsoc00Agg  gwtall dpaidwk country ///
		region, before(bchoice)




*===============================================================================
*GRAPHS OF SKILL USE BY OCCUPATION GROUP
*===============================================================================

do "code/process_LFS/aggregate_occupations.do"

*do "code/process_SES/create_descriptive_graphs.do"


*===============================================================================
*SKILL INDEXES
*===============================================================================

local abstract 		clong cwritelg ccalca cpercent cstats cplanoth csolutn canalyse
local social		cpeople cteach cspeech cpersuad cteamwk clisten
local routine		brepeat bvariety cplanme bme4 
local manual		chands cstrengt cstamina


local variable_list `abstract' `social' `routine' `manual'

cap drop temp*
local count=1
*Dropping incomplete cases
foreach variable in `variable_list' { 
	g tempMiss`count'=missing(`variable')
	local ++count	
}

egen 	complete_cases=rowtotal(temp*)
replace	complete_cases=(complete_cases==0)

drop 	temp*

drop if !complete_cases


*===============================================================================
*I FIX THE VARIABLE RANGE FROM 0 TO 1
*===============================================================================		
foreach variable in `variable_list' {
	qui summ `variable'
	replace `variable'=`variable'-`r(min)'
	replace `variable'=`variable'/(`r(max)'-`r(min)')

	qui summ `variable'

	di "`variable'"
	assert `r(max)'==1
	assert `r(min)'==0
}

*At this point I converted all variables to the 0-1 range

*===============================================================================
*MAKING SURE ALL VARIABLES ARE IN THE SAME DIRECTION
*===============================================================================	

local index_list abstract social routine manual

cap log close
log using "results/log_files/index_composition.txt", text replace
foreach index in `index_list' {
	di "Variables in `index'"
	descr ``index''
}
log close


cap log close
log using "results/log_files/index_correlations.txt", text replace

foreach index in `index_list' {
	pwcorr ``index''
}

log close

/*
*cplanme and cplanoth have the wrong direction

replace cplanme=-cplanme+1
replace cplanoth=-cplanoth+1

log using "results/log_files/index_correlations.txt", text append

di "correlations after correction of direction"

local index_list abstract social routine manual

foreach index in `index_list' {
	cap pwcorr ``index''
}

*===============================================================================
*GENERATING SKILL INDEXES
*===============================================================================	
foreach index in abstract social routine manual {
	cap drop temp
	egen temp=rowmean(``index'')
	egen `index'=std(temp)
}

*Everything looks good here
pwcorr `index_list'
log close


*===============================================================================
*SKILL USE BY EDUCATION LEVEL
*===============================================================================	
drop if year==1997

rename edlev edlevLFS

do "code/process_LFS/create_education_variables.do"

log using "results/log_files/skill_use_education.txt", text replace

*Average skill use by education, all years

table educ_3_low [fw=gwtall], c(mean abstract mean social mean routine   mean manual) format(%9.2fc)

table educ_3_mid [fw=gwtall], c(mean abstract mean social mean routine   mean manual)  format(%9.2fc)

log close

*===============================================================================
*CHARACTERIZING OCCUPATIONS ACCORDING TO THEIR SKILL USE
*===============================================================================	


save "data/additional_processing/SES_skill_index_database.dta", replace

collapse (mean) `index_list' (count) people=educ_4 [fw=gwtall], by(bsoc00Agg occ_1dig)
grstyle init
grstyle set symbol lean


graph dot  `index_list' [fw=people], over(occ_1dig) yline(0) ///
	legend(order(1 "Abstract" 2 "Social" 3 "Routine" 4 "Manual")) ///
	title("Average skill use by occupation group")

graph export "results/figures/skill_use_occ_group.png", replace


cap log close
log using "results/log_files/skill_occupation_examples.txt", text replace
foreach index in `index_list' {
	gsort -`index'
	di "Occupations at the top of `index'"
	list bsoc00Agg if inrange(_n,1,10)

	di "Occupations at the bottom of `index'"
	list bsoc00Agg if inrange(_n,_N-10,_N)	
}
log close 



/*
*===============================================================================
*OLD CODE TO DISCARD
*===============================================================================
local analyticalList 	cpeople cteach cpersuad cplanoth canalyse csolutn ///
						ccalca cpercent cwritelg cwritesh clong cshort
local manualList		cstamina cstrengt chands ctools
local RList				brepeat bvariety cplanme bme4 
local newManualList		`manualList' brepeat bvariety cplanme



*===============================================================================
*Creating computer complexity 
*===============================================================================
g bcuse=		 		dusepc>=2
replace bcuse=0 		if cusepc==1

g bmuse=  				dusepc>=3
replace bmuse=0 		if cusepc==1

g bouse=			 	dusepc>=4
replace bouse=0 if 		cusepc==1

g mouse=				inrange(dusepc, 3,4)
replace mouse=0 if 		cusepc==0

g 			controutineuse= 			(dusepc-1)/4
replace		controutineuse=0			if cusepc==1

local pcMeasureList bcuse bmuse bouse mouse

foreach index in `indexTypeList'{
	foreach variable in `pcMeasureList' {
		g `variable'`index'=`variable'
		g `variable'`index'_sd=`variable'
	}
}

*/