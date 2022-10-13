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

        cap drop temp
        *Filtering by number of education levels in the job
        gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
        egen n_educ=max(temp), by(occupation year)
        keep if n_educ==3

        *keep if inlist(occupation, 1121,1122)

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

    tempvar temp
    gegen `temp'=nunique(education) if equation==1, by(occupation)
    egen n_education=max(`temp'), by(occupation)

    keep if n_education==3

}


*drop if equation==1

*Now I expand the dataset with all the variables I need to create the GMM errors
*Added zero restriction
*{
    local var_counter=0
    di "Expanding equation 1 variables", as result
    qui forvalues education=1/$n_educ {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&education==`education'&equation==1
                local index_counter=1
                    foreach index in $index_list {
                        if `r(N)'!=0 & "`index'"!="$ref_skill_name" {
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
                if `r(N)'!=0 & "`index'"!="$ref_skill_name" {
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


    cap drop z_*
    forvalues educ=1/3 {
        foreach index in $index_list {
            if "`index'"!="$ref_skill_name" {
                cap drop temp 
                cap drop z_`index'_e`educ'
                generate temp=`index' if education==`educ' & equation==1
                generate temp_size=obs if education==`educ' & equation==1
                egen z_`index'_e`educ'=max(temp), by(skill occupation year)
                egen zs_`index'_e`educ'=sum(temp_size), by(skill occupation year)
                cap drop temp 
            }
        }
    }


    foreach index in $index_list {
        if "`index'"!="$ref_skill_name" {
            
            *z_`index'_e gives the index
            *zs_`index'_e gives the occupation size


            generate z_`index'_1=.
            generate zs_`index'_1=.
            replace z_`index'_1=z_`index'_e2 if education==1&equation==1
            replace zs_`index'_1=zs_`index'_e2 if education==1&equation==1
            replace z_`index'_1=z_`index'_e1 if inlist(education,2,3)&equation==1
            replace zs_`index'_1=zs_`index'_e1 if inlist(education,2,3)&equation==1


            generate z_`index'_2=.
            generate zs_`index'_2=.
            replace z_`index'_2=z_`index'_e2 if education==3&equation==1
            replace zs_`index'_2=zs_`index'_e2 if education==3&equation==1
            replace z_`index'_2=z_`index'_e3 if inlist(education,1,2)&equation==1
            replace zs_`index'_2=zs_`index'_e3 if inlist(education,1,2)&equation==1
     
            egen zt_`index'=rowtotal(zs_`index'_1 zs_`index'_2)

            generate zw_`index'_1= zs_`index'_1/ zt_`index'
            generate zw_`index'_2= zs_`index'_2/ zt_`index'
        
        
            generate zv_`index'=zw_`index'_1*z_`index'_1+zw_`index'_2*z_`index'_2 if equation==1
        }
     
    }

    order occupation  year skill education manual social routine abstract z*_1 z*_2 zv*, first
    sort equation skill  occupation year  education


    *Creating skill levels of other education levels
    
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&year_id==`year'&equation==1
            local index_counter=1
            foreach index in $index_list {
                if `r(N)'!=0 & "`index'"!="$ref_skill_name" {
                    qui generate z1s_`index_counter'_`job'_`year'=0
                    qui replace z1s_`index_counter'_`job'_`year'= zv_`index' if occ_id==`job'&year_id==`year'&equation==1
                    
                    local ++var_counter
                }
                local ++index_counter
            }
        }
    }

    *Note 10/13/22 this bit seems to be ok


    *I also verified that the depednet variable is constructed appropriately

    local drop_counter=0
    *Note: I made sure that I was not excluding 1 education level fully.
    foreach variable of varlist z1s* {
        cap qui summ `variable'
        if `r(max)'==0 {    
            drop `variable'
            local ++drop_counter
        }

    }
    di "Null variables:  `drop_counter'"


    order e1s_* z1s_* i_* ts_*, last
    
    *Here I filter the jobs that 
    sort equation education occupation year skill  

    *Adding line for inst



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

order e1s* i_* e2*, last

save "data/additional_processing/gmm_example_dataset", replace

*This creates the ln vector in the right order; first it goes through skills, next through years and finally through jobs.
cap drop ln_alpha
egen ln_alpha=group(occupation skill year) if equation==1&skill!=$ref_skill_num
order ln_alpha, after(equation)
export delimited using  "data/additional_processing/gmm_example_dataset.csv", replace



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