/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compute_gmm.do
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
This do file creates the dataset I need to execute the GMM code in matlab


*Latest log of chances:
- Drop code from equations 2 and 3


*/

global ref_skill_num    4
global ref_skill_name   abstract


*Final dataset touches
{
    { 
        *Including only jobs I have observations for
        use "data/additional_processing/gmm_skills_dataset", clear

        cap drop skill_sum
        generate skill_sum=26.6893959439257*manual+47.4324378083784*social+42.5900598551701*routine+25.0523127821848*abstract if education==1
        replace skill_sum=50.6893959439257*manual+19.4324378083784*social+58.5900598551701*routine+49.0523127821848*abstract if education==2
        replace skill_sum=51.6893959439257*manual+69.4324378083784*social+23.5900598551701*routine+13.0523127821848*abstract if education==3

        keep if inlist(occupation, 1112,1121,1122)

        drop if missing(y_var)
        sort equation occupation year education


        egen n_obs=count(manual) if equation==1, by(occupation year)

        drop if n_obs==4


        keep occupation year 

        duplicates drop 

        tempfile job_filter
        save `job_filter'

    }

    {
        use "data/additional_processing/gmm_employment_dataset", clear
        drop if missing(y_var)
        keep if equation==3

        keep occupation year 
        duplicates drop 

        tempfile employment_filter
        save `employment_filter'
    }

    *Files for instrument
    {
        use "data/additional_processing/gmm_employment_dataset", clear
        drop if missing(y_var)
            
        preserve
            keep occupation education_d year indexd*
            forvalues skill=1/4 {
                rename indexd`skill' index`skill'
            }
            rename education_d education

            tempfile denominator
            save `denominator'
        restore

        keep occupation education index1-index4 year
        append using `denominator'

        duplicates drop 

        reshape wide index*, i(occupation year) j(education)
    }


    use "data/additional_processing/gmm_skills_dataset", clear

    append using "data/additional_processing/gmm_employment_dataset"

    merge m:1 occupation year using `job_filter', keep(3) nogen
    merge m:1 occupation year using `employment_filter', keep(3) nogen 


    drop if missing(y_var)

    sort equation skill occupation  year   education   


    egen occ_id=group(occupation)
    egen year_id=group(year)

    unique occupation
    global n_jobs=`r(unique)'

    *Creating gmm error equations:
    qui {
        levelsof occ_id
        global jobs "`r(levels)'"

        levelsof year_id 
        global years "`r(levels)'"

        levelsof education 
        global educ_lev "`r(levels)'"

        qui summ education 
        *Defining globals
        global n_educ=`r(max)'
        di "$n_educ"

        qui summ skill
        global n_skills=`r(max)'
        di "$n_skills"
    }

    keep if inlist(equation,1,2)
    keep occupation-equation occ_id year_id


}






*Now I expand the dataset with all the variables I need to create the GMM errors
*{
    local var_counter=0
    di "Expanding equation 1 variables", as result
    qui forvalues education=1/$n_educ {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&education==`education'&equation==1
                local index_counter=1
                    foreach index in $index_list {
                        if `r(N)'!=0 {
                            qui generate e1s_`index_counter'_`education'_`job'_`year'=0
                            qui replace e1s_`index_counter'_`education'_`job'_`year'= `index' if occ_id==`job'&year_id==`year'&equation==1&education==`education'
                            local ++var_counter
                        }
                        local ++index_counter
                    }
            }
        }
    }

    di "`var_counter' variables were generated."

    local var_counter=0
    di "Creating equation 1 dummies", as result

    foreach job in $jobs {
        foreach year in $years {
            local counter=1
            local index_counter
            qui summ  year if occ_id==`job'&year_id==`year'
            foreach index in $index_list {
                if `r(N)'!=0 {
                    qui generate i_`index'_`job'_`year'=0
                    qui replace i_`index'_`job'_`year'=-1 if occ_id==`job'&year_id==`year'&skill==`counter'&equation==1
                
                    local ++var_counter
                }
                
                local ++counter
            }
        }
    }


    cap drop e2_index_*
    forvalues education=1/$n_educ {
        local index_counter=1
        foreach index in $index_list {
            generate e2_index_`index_counter'_`education'=0
            qui replace e2_index_`index_counter'_`education'=`index' if equation==2 & education==`education'
            local ++index_counter
        }
    }


    di "Creating omega restriction variables", as result
    *Creating equation 2 variables
    foreach education in $educ_lev {
    qui summ  year if education==`education'&equation==2
    foreach index in $index_list {
        if `r(N)'!=0 {
            generate ts_`index'`education'=0
            replace ts_`index'`education'= `index' if education==`education'&equation==2
        }
    }
    }


    *Here I filter the jobs that 


    sort equation education occupation year skill  


/*
di "Expanding employment equation variables", as result
*Creating equation 3 variables

foreach variable of varlist index1-index4 {
    rename `variable' ezn_`variable'
    replace  ezn_`variable'=0 if missing(ezn_`variable')
}

foreach variable of varlist indexd1-indexd4 {
    rename `variable' ezd_`variable'
    replace  ezd_`variable'=0 if missing(ezd_`variable')
}



order en_* ed_* ezn_* ezd_*, last
order education_d, after(education)
egen ee_group_id=group(education education_d) if equation==3


levelsof ee_group_id
foreach pair in `r(levels)' {
    foreach year in $years {
        generate x_`pair'`year'=0
        replace x_`pair'`year'=1 if ee_group_id==`pair'&year_id==`year'
    }
}

foreach year in $years {
    cap label var x_1`year' "Low/High"
    cap label var x_2`year' "Mid/Low"
    cap label var x_3`year' "High/Mid"
}

br education education_d year x*

*drop x_11 x_13

drop ee_group_id
egen ee_group_id=group(education education_d year)
order ee_group_id, after(education_d)

*/


save "data/additional_processing/gmm_example_dataset", replace

*This creates the ln vector in the right order; first it goes through skills, next through years and finally through jobs.

cap drop ln_alpha
egen ln_alpha=group(occupation skill year)
order ln_alpha, after(equation)
export delimited using  "data/additional_processing/gmm_example_dataset.csv", replace


*This part of the code didn't work
/*
{
    keep if equation==2

    egen group_id=group(occupation education)
    xtset group_id year_id

    foreach variable in $index_list { 
        generate d_`variable'=d.`variable'
    }

    generate d_y_var=0
    generate d_y_var_3=-d_manual


    regress d_y_var_3 i.education#c.(d_routine d_abstract d_social), nocons
}
*/