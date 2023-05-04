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


    do "code/process_SES/compute_skill_indexes.do"


    eststo clear

    keep if inlist(year,2001,2017)

    eststo clear
    foreach year in 2001 2017 {
        foreach skill in $index_list {
        eststo `skill'`year': regress `skill' ibn.education if year==`year', nocons
        }
    }


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

collapse (mean) l_hourpay (sum) people [aw=people], by($education year)
egen temp=sum(people), by(year)
generate emp_share=people/temp 

keep if inlist(year, 2001,2017)

table $education year, c(mean emp_share)

