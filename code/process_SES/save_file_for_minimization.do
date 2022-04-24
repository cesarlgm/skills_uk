
local education `1'



use "data/temporary/filtered_dems_SES", clear

replace cplanoth=6-cplanoth

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


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

*===============================================================================
*SKILL INDEXES
*===============================================================================

local abstract 		cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
local social		cpeople cteach  cspeech cpersuad cteamwk clisten
local routine		brepeat bvariety cplanme bme4 
local manual		chands cstrengt  cstamina
local index_list 	abstract social routine manual 

local variable_list  `manual' `routine' `abstract' `social' 


foreach index in `index_list' {
	cap pwcorr ``index''
}


cap drop temp*
local count=1
*Dropping incomplete cases
foreach variable in `variable_list' { 
	g tempMiss`count'=missing(`variable')
	local ++count	
	summ `variable'
	g n_`variable'=(`variable'-`r(min)')/(`r(max)'-(`r(min)'))
}

egen 	complete_cases=rowtotal(temp*)
replace	complete_cases=(complete_cases==0)

drop 	temp*

drop if !complete_cases


local abstract_i 	n_clong 	n_cwritelg n_ccalca n_cpercent n_cstats n_cplanoth n_csolutn n_canalyse
local social_i		n_cpeople	n_cteach n_cspeech n_cpersuad n_cteamwk n_clisten
local routine_i		n_brepeat 	n_bvariety n_cplanme n_bme4 
local manual_i		n_chands 	n_cstrengt n_cstamina
local index_list_i 	n_abstract  n_social   n_routine manual 


egen    temp=group(bme4)
drop bme4
rename temp bme4


keep bsoc00Agg `education' year `variable_list' gwtall 
order  bsoc00Agg `education' year `variable_list' 


export delimited "data/additional_processing/file_for_minimization.csv", ///
	replace nolabel 
