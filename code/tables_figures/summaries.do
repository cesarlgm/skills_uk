*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	regressions tables focussing on different measures of routine 
				pc use.
	
	output: skill_use_within_jobs

*/
*===============================================================================


*SUMMARY TABLES: SKILL USE CHANGES
*===============================================================================
*========================================================
*GETTING CORRELATIONS WITHIN INDEXES
*========================================================


*FULL SET OF OCCUPATIONS
*===========================================================================
local def `1'

eststo clear 
*I set up filters to keep the number of occupations consistent across files

{
    global education educ_3_low

    use "data/temporary/filtered_dems_SES", clear
    drop if missing(gwtall)


    rename edlev edlevLFS
    do "code/process_LFS/create_education_variables.do"


    do "code/aggregate_SOC2000.do"

    merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

    keep if  n_years==4

    rename $education education
    rename bsoc00Agg occupation

    preserve 
        keep occupation
        duplicates drop
        tempfile SES_occs
        save `SES_occs'
    restore

    do "code/process_SES/compute_skill_indexes.do"  `def'


    eststo clear

    keep if inlist(year,2001,2017)

    eststo clear
    foreach year in 2001 2017 {
        foreach skill in $index_list abstract`def' {
        eststo `skill'`year': regress `skill' ibn.education if year==`year' [aw=gwtall], nocons
        }
    }

    table education, c(mean manual mean social mean routine mean abstract`def')

    summ $index_list  abstract`def'



    *Information for table with changes in skill use
    esttab manual*, nostar not

    esttab social*, nostar not

    esttab routine*, nostar not

    esttab abstract*, nostar not
}

*SUMMARY TABLES: EMPLOYMENT SHARES
*===============================================================================
use "./data/temporary/LFS_agg_database", clear

do "code/process_LFS/create_education_variables.do"

rename $occupation occupation
merge m:1 occupation using  `SES_occs', keep(3)

collapse (mean) l_hourpay (count) people [fw=people], by($education year)
egen temp=sum(people), by(year)
generate emp_share=people/temp 

keep if inlist(year, 2001,2017)

table $education year, c(mean emp_share)

*=========================================================================================================

*=========================================================================================================

eststo clear 
*I set up filters to keep the number of occupations consistent across files

{
    global education educ_3_low

    use "data/temporary/filtered_dems_SES", clear
    drop if missing(gwtall)




    rename edlev edlevLFS
    do "code/process_LFS/create_education_variables.do"


    do "code/aggregate_SOC2000.do"

    merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

    keep if  n_years==4

    rename $education education
    rename bsoc00Agg occupation

    merge m:1 occupation using  "data/additional_processing/GMM_occupation_filter_two_equation", keep(3) nogen 
   

    do "code/process_SES/compute_skill_indexes.do"


    eststo clear

    keep if inlist(year,2001,2017)

    eststo clear
    foreach year in 2001 2017 {
        foreach skill in $index_list {
        eststo `skill'`year': regress `skill' ibn.education if year==`year' [aw=gwtall], nocons
        }
    }

    table education, c(mean manual mean social mean routine mean abstract`def')

    summ $index_list



    *Information for table with changes in skill use
    esttab manual*, nostar not

    esttab social*, nostar not

    esttab routine*, nostar not

    esttab abstract*, nostar not
 
}



*SUMMARY TABLES: EMPLOYMENT SHARES
*===============================================================================
use "./data/temporary/LFS_agg_database", clear

do "code/process_LFS/create_education_variables.do"

rename $occupation occupation 
rename $education education
merge m:1 occupation using  "data/additional_processing/GMM_occupation_filter_two_equation", keep(3) nogen 

unique occupation



*gcollapse (sum) people, by(education year)

*tab education year [fw=people] if inlist(year,2001,2006,2012,2017)


gcollapse (mean) l_hourpay (count) people [fw=people], by(education year)
egen temp=sum(people), by(year)
generate emp_share=people/temp 

keep if inlist(year, 2001,2017)

table education year, c(mean emp_share)

