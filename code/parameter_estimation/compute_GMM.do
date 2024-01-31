/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compute_gmm.do
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
This do file creates the dataset I need to execute the GMM code in matlab


*Latest log of chances:
- Drop code from equations 2 and 3


*/


*Final dataset touches
{
   { 
        *Including only jobs I have observations for
        use "data/additional_processing/gmm_skills_dataset`1'", clear

        cap drop temp
        *Filtering by number of education levels in the job
        gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
        egen n_educ=max(temp), by(occupation year)
        keep if n_educ==3

        *keep if inlist(occupation, 1121,1122)

        drop if missing(y_var)
        sort equation occupation year education


        egen n_obs=count(y_var) if equation==1, by(occupation year)
    
        drop if n_obs==4


        keep occupation year 

        duplicates drop 

        tempfile job_filter
        save `job_filter'

    }

    use "data/additional_processing/gmm_skills_dataset`1'", clear

    append using "data/additional_processing/gmm_employment_dataset`1'"

    merge m:1 occupation year using `job_filter', keep(3) nogen


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

    }

    keep if inlist(equation,1,2)
    keep occupation-equation occ_id year_id

    tempvar temp
    gegen `temp'=nunique(education) if equation==1, by(occupation)
    egen n_education=max(`temp'), by(occupation)

    keep if n_education==3

}

/*
*drop if equation==1

*Now I expand the dataset with all the variables I need to create the GMM errors
*Added zero restriction
    local var_counter=0
    di "Expanding equation 1 variables", as result
    qui forvalues education=1/$n_educ {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&education==`education'&equation==1
                local index_counter=1
                    foreach index in $index_list {
                        if `r(N)'!=0  /* & "`index'"!="$ref_skill_name" */   {
                            qui generate e1s_`index_counter'_`education'_`job'_`year'=0
                            qui replace e1s_`index_counter'_`education'_`job'_`year'= 1 if occ_id==`job'&year_id==`year'&equation==1&education==`education'
                            local ++var_counter
                        }
                        local ++index_counter
                    }
            }
        }
    }
    */


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

    

    order occupation  year skill education $index_list , first
    sort equation skill  occupation year  education


    *Here I filter the jobs that 
    sort equation education occupation year skill  



order e2* ts_*, last

save "data/additional_processing/gmm_example_dataset_eq6`1'", replace

*This creates the ln vector in the right order; first it goes through skills, next through years and finally through jobs.
cap drop ln_alpha
egen theta_code=group(education skill) if equation==1
generate temp=theta_code if skill==1 & equation==1

egen theta_code_den=max(temp) if equation==1, by(occupation education year)

egen job_index=group(occupation) if equation==1
egen ln_alpha=group(occupation  year skill) if equation==1 //&skill!=$ref_skill_num
order ln_alpha job_index theta_code theta_code_den, after(year)

preserve
    keep occupation
    duplicates drop 
    save "data/additional_processing/GMM_occupation_filter_two_equation", replace
restore


order y_var, after(education)


sort equation education occupation  year skill
by equation education occupation year: generate new_y_var=y_var-y_var[1] if equation==1
order new_y_var, after(y_var)

drop if skill==1&equation==1

cap drop ln_alpha 
egen ln_alpha=group(occupation  year skill) if equation==1

drop if equation==2

drop y_var
rename new_y_var y_var

xi i.theta_code, noomit pref(g1)

xi i.ln_alpha, noomit pref(g2)

xi i.job_index, noomit pref(g3)

export delimited using  "data/additional_processing/gmm_example_dataset_eq6`1'.csv", replace nolabel



*y_var is appropriate set to 1 for equatip¡on 2




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