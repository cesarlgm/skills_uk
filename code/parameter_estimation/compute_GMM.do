{ 
    *Including only jobs I have observations for
    use "data/additional_processing/gmm_skills_dataset", clear


    drop if missing(y_var)
    sort equation occupation year education

    keep if equation==1

    egen n_obs=count(manual) if equation==1, by(occupation year )

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

use "data/additional_processing/gmm_skills_dataset", clear

append using "data/additional_processing/gmm_employment_dataset"


merge m:1 occupation year using `job_filter', keep(3) nogen
merge m:1 occupation year using `employment_filter', keep(3) nogen 

sort equation education  occupation  year skill

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


/*
*Dataset creation
{
    
    local var_counter=0
    di "Expanding equation 1 variables", as result
    qui foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'
                foreach index in $index_list {
                    if `r(N)'!=0 {
                        qui generate `index'`education'_`job'`year'=0
                        qui replace `index'`education'_`job'`year'= `index' if occ_id==`job'&year_id==`year'&equation==1
                        local ++var_counter
                    }
                }
            }
        }
    }

    di "`var_counter' variables were generated."

    local var_counter=0
    di "Creating equation 1 dummies", as result
    qui foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
                local counter=1
                local index_counter
                qui summ  year if occ_id==`job'&year_id==`year'&equation==1
                foreach index in $index_list {
                    if `r(N)'!=0 {
                        qui generate i_`index'`education'_`job'`year'=0
                        qui replace i_`index'`education'_`job'`year'=-1 if education==`education'&occ_id==`job'&year_id==`year'&skill==`counter'
                    
                        local ++var_counter
                    }
                    
                    local ++counter
                }
            }
        }
    }

    di "`var_counter' variables were generated."

    local var_counter=0
    di "Creating omega restriction variables", as result
    *Creating equation 2 variables
    *I think this part doesn't make a difference. I should ask Kevin about this.
    qui foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&equation==2
                foreach index in $index_list {
                    if `r(N)'!=0 {
                        qui generate ts_`index'`education'_`job'`year'=0
                        qui replace ts_`index'`education'_`job'`year'= `index' if occ_id==`job'&year_id==`year'&equation==2
                        local ++var_counter
                    }
                }
            }
        }
    }


    local var_counter=0
    di "`var_counter' variables were generated."

    di "Expanding employment equation variables", as result
    *Creating equation 3 variables
    foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
               qui summ  year if occ_id==`job'&year_id==`year'&equation==3
               forvalues index=1/$n_skills {  
                    if `r(N)'!=0 {
                        qui generate ee_index`index'_`education'_`job'`year'=0
                        qui replace ee_index`index'_`education'_`job'`year'= index`index' if occ_id==`job'&year_id==`year'&equation==3

                        qui generate ee_index`index'_`education'_`job'`year'_d=0
                        qui replace ee_index`index'_`education'_`job'`year'_d= indexd`index' if occ_id==`job'&year_id==`year'&equation==3
                        local var_counter=`var_counter'+2
                    }
                }
            }
        }
    }   

    order *_d, last

    egen ee_group_id=group(education education_d) if equation==3

    levelsof ee_group_id
    foreach pair in `r(levels)' {
        foreach year in $years {
            generate x_`pair'`year'=0
            replace x_`pair'`year'=1 if ee_group_id==`pair'&year_id==`year'
        }
    }

    foreach year in $years {
        label var x_1`year' "Low/High"
        label var x_2`year' "Mid/Low"
        label var x_3`year' "High/Mid"
    }
    save "data/additional_processing/final_GMM_dataset", replace
}


use "data/additional_processing/final_GMM_dataset", clear
*Setting variable names
{
    global first_var manual1_11
    global last_var abstract3_${n_jobs}3

    global ee_first_var ee_index1_1_11
    global ee_last_var ee_index4_3_${n_jobs}3

    qui ds $ee_first_var-$ee_last_var
    global ee_names `r(varlist)'

    qui ds x_*
    global x_names `r(varlist)'

    global ee_first_var_d ee_index1_1_11_d
    global ee_last_var_d ee_index4_3_${n_jobs}3_d

    qui ds $ee_first_var_d-$ee_last_var_d
    global ee_names_d `r(varlist)'

    qui ds $first_var-$last_var
    global names "`r(varlist)'"

    qui ds i_$first_var-i_$last_var
    global names_dummy "`r(varlist)'"

    qui ds ts_*
    global ts_names "`r(varlist)'"

    get_ts_vec_length
    global ts_length=`r(length1)'
}

local trial:  word count $ts_names
di `trial'

count_parameters
matrix define trial=J(`r(total_parameters)',1,.)
forvalues j=1/`r(total_parameters)' {
    matrix define trial[`j',1]=`j'
}

count_parameters

get_job_indexes, nda(`r(n_d_ln_A)')

equation_1_error, at(trial)


/*

equation_1_error, at(trial) job_index(job_index)

total_skill_error, at(trial) 



/*


matrix define job_index=r(job_index)

matrix list r(job_index)

return list 


matrix list trial

equation_1_error, at(trial)

matrix define sigma=r(sigma)
matrix define theta=r(theta)
matrix define lambda=r(lambda)

assign_sigmas, sigma_vec(sigma) job_index(job_index)

split_theta, theta(theta) n_educ(3) l_A(458)
forvalues e=1/3 {
    matrix define theta`e'=r(theta`e')
}


split_lambda, theta_mat(theta) n_educ(3) lambda_mat(lambda)


/*
qui ds manual4*
local n_1: word count `r(varlist)'
di "`n_1'"

mata  
c=J(108,1,(1 \ 2 \ 3 \ 4))
st_matrix("trial",c)
end
matrix list trial



/*


keep if equation==1
keep occupation year education $index_list y_var skill occ_id year_id


drop if missing(y_var)


foreach education in $educ_lev {
    foreach job in $jobs {
        foreach year in $years {
            foreach index in $index_list {
                qui generate `index'`education'`job'`year'=0
                qui replace `index'`education'`job'`year'= `index' if education==`education'&occ_id==`job'&year_id==`year'

            }
            qui generate y`education'`job'`year'=0
            qui replace  y`education'`job'`year'=y_var if education==`education'&occ_id==`job'&year_id==`year'
        }
    }
}


*Creating equations
global equation_list 
global inst_list
foreach education in $educ_lev {
    foreach job in $jobs {
        foreach year in $years {
            local spec 
            local kcounter=1
            foreach index in $index_list {
                local spec `spec' -{theta`kcounter'`education'=1}*`index'`education'`job'`year'
                local instspec  `instspec' `index'`year'`job'`education'
                local ++kcounter
            }
            global eq`job'`year'`education' (eq`job'`year'`education': 1- `spec')
            global inst_list`job'`year'`education' instruments(eq`job'`year'`education': `instspec')

            global equation_list $equation_list ${eq`job'`year'`education'}
            *global inst_list $inst_list ${inst_list`job'`year'`education'}
        }
    }
}

gmm $equation_list, winitial(identity)