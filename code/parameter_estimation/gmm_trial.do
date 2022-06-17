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


drop if missing(y_var)
keep if inlist(occupation, 1112,1121,1131,1134)&inlist(year,2006,2012)



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

*Dataset creation
{

local var_counter=0
di "Expanding equation 1 variables", as result

foreach education in $educ_lev {
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&year_id==`year'&education==`education'
            local index_counter=1
            foreach index in $index_list {
                if `r(N)'!=0 {
                    qui generate a_index_`education'_`index_counter'_`job'_`year'=0
                    qui replace a_index_`education'_`index_counter'_`job'_`year'= `index' if occ_id==`job'&year_id==`year'&equation==1&education==`education'
                    local ++var_counter
                }
                local ++index_counter
            }
        }
    }
}


*Instruments for equation 1
local var_counter=0
foreach job in $jobs {
    foreach year in $years {
        qui summ  year if occ_id==`job'&year_id==`year'
        local index_counter=1
        foreach index in $index_list {
            if `r(N)'!=0 {
                qui generate e1_index_`index_counter'_`job'_`year'=0
                qui replace e1_index_`index_counter'_`job'_`year'= `index' if occ_id==`job'&year_id==`year'&equation==1
                local ++var_counter
            }
            local ++index_counter
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
        qui summ  year if occ_id==`job'&year_id==`year'&equation==1
        foreach index in $index_list {
            if `r(N)'!=0 {
                qui generate i_`index'_`job'_`year'=0
                qui replace i_`index'_`job'_`year'=-1 if occ_id==`job'&year_id==`year'&skill==`counter'
            
                local ++var_counter
            }
            
            local ++counter
        }
    }
}

di "`var_counter' variables were generated."

local var_counter=0
di "Creating omega restriction variables", as result
*Creating equation 2 variables
*I think this part doesn't make a difference. I should ask Kevin about this.
qui foreach education in $educ_lev {
    qui summ  year if education==`education'&equation==2
    foreach index in $index_list {
        if `r(N)'!=0 {
            qui generate ts_`index'`education'=0
            qui replace ts_`index'`education'= `index' if education==`education'&equation==2
            local ++var_counter
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
            qui summ  year if occ_id==`job'&year_id==`year'&equation==3&education==`education'
            forvalues index=1/$n_skills {  
                if `r(N)'!=0 {
                     generate en_index_`index'_`education'_`job'_`year'=0
                     replace  en_index_`index'_`education'_`job'_`year'= index`index' if occ_id==`job'&year_id==`year'&education==`education'&equation==3
                    local var_counter=`var_counter'+1
                }
            }
        }
    }
}

foreach education in $educ_lev {
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&year_id==`year'&equation==3&education_d==`education'
            forvalues index=1/$n_skills {  
                if `r(N)'!=0 {
                    generate ed_index_`index'_`education'_`job'_`year'=0
                    replace  ed_index_`index'_`education'_`job'_`year'= indexd`index' if occ_id==`job'&year_id==`year'&education_d==`education'&equation==3
                    local var_counter=`var_counter'+1
                }
            }  
       }
    }
}

}




order en_* ed_*, last
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
    label var x_1`year' "Low/High"
    label var x_2`year' "Mid/Low"
    label var x_3`year' "High/Mid"
}

br education education_d year x*

drop ee_group_id
egen ee_group_id=group(education education_d year)
order ee_group_id, after(education_d)


save "data/additional_processing/gmm_example_dataset", replace


egen ln_alpha=group(occupation skill year)
order ln_alpha, after(equation)
export delimited using  "data/additional_processing/gmm_example_dataset.csv", replace

