global education educ_3_low


frames reset

*Pre-regression cleaning
{
	use "data/temporary/LFS_agg_database", clear

	do "code/process_LFS/create_education_variables.do"

	generate temp=1

    replace year=2001 if inlist(year,2001,2002,2003)
    replace year=2017 if inlist(year,2015,2016,2017)

    keep if inlist(year,2001,2017)

	gcollapse (mean) grossWkPayMain hourpay al_* l_hourpay l_wkpay l_gpay (sum) temp [fw=people], by($occupation year $education)

    rename temp people

    egen obs_id=group($occupation $education)
    egen time_counter=group(year)

    xtset obs_id time_counter

    foreach variable of varlist l_* al_* {
        generate d_`variable'=d.`variable'
    }

    generate temp=l.people
    replace people=temp
    drop temp

    
    drop if year==2001
    /*
    replace year=2001 if year==2006
    replace year=2006 if year==2012
    replace year=2012 if year==2017
    */
    replace year=2001 if year==2017 
    *Adding SES information
}

generate database=2

rename people weight

rename $occupation occupation
rename $education education

save "data/additional_processing/regression_wage_dataset", replace
