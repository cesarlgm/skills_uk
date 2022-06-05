use "data/additional_processing/gmm_skills_dataset", clear

sort education equation       occupation  year skill

drop if missing(y_var)

egen occ_id=group(occupation)
egen year_id=group(year)

*Creating gmm error equations:
levelsof occ_id
global jobs `r(levels)'

levelsof year_id 
global years `r(levels)'

levelsof education 
global educ_lev `r(levels)'



foreach education in $educ_lev {
    foreach job in $jobs {
        foreach year in $years {
            foreach index in $index_list {
                qui summ  `index' if occ_id==`job'&year_id==`year'  
                if `r(N)'!=0 {
                    qui generate `index'`education'_`job'`year'=0
                    qui replace `index'`education'_`job'`year'= `index' if occ_id==`job'&year_id==`year'&equation==1
                }
            }
        }
    }
}


global first_var manual1_11
global last_var abstract3_1553

qui ds $first_var-$last_var
global names "`r(varlist)'"

foreach education in $educ_lev {
    foreach job in $jobs {
        foreach year in $years {
            local counter=1
            local index_counter
            foreach index in $index_list {
                qui summ  `index' if occ_id==`job'&year_id==`year'
                if `r(N)'!=0 {
                    qui generate i_`index'`education'_`job'`year'=0
                    qui replace i_`index'`education'_`job'`year'=-1 if education==`education'&occ_id==`job'&year_id==`year'&skill==`counter'
                }
                
                local ++counter
            }
        }
    }
}


*Creating equation 2 variables
*I think this part doesn't make a difference. I should ask Kevin about this.
    foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
                foreach index in $index_list {
                    qui summ  `index' if occ_id==`job'&year_id==`year'  
                    if `r(N)'!=0 {
                        qui generate ts_`index'`education'_`job'`year'=0
                        qui replace ts_`index'`education'_`job'`year'= `index' if occ_id==`job'&year_id==`year'&equation==2
                    }
                }
            }
        }
    }


qui ds i_$first_var-i_$last_var
global names_dummy "`r(varlist)'"

count_parameters
matrix define trial=J(`r(total_parameters)',1,.)
forvalues j=1/`r(total_parameters)' {
    matrix define trial[`j',1]=`j'
}

equation_1_error, at(trial) job_index(job_index)

total_skill_error, at(trial)



/*
count_parameters

get_job_indexes, nda(`r(n_d_ln_A)')

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