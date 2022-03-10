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

	gcollapse (mean) grossWkPayMain hourpay al_* l_hourpay l_wkpay l_gpay (sum) temp [fw=people], by($occupation year $education industry_cw)

    rename temp people

    egen obs_id=group($occupation $education industry_cw)
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
    {
        frame create SES_occs
        frame change SES_occs
        do "code/process_SES/save_file_for_minimization.do"

        do "code/process_SES/compute_skill_indexes.do"

        gcollapse (mean)  $index_list (count) obs=chands (sum) wobs=gwtall, by($occupation $education year) 

        tempfile SES_data
        save `SES_data'
    }

    frame change default
    merge m:1 $occupation $education year using `SES_data', keep(3) nogen
}

