global ref_skill_num    4
global ref_skill_name   abstract

{ 
    *Including only jobs I have observations for
    use "data/additional_processing/gmm_skills_dataset", clear

    drop if missing(y_var)
    sort equation occupation year education

    keep if equation==1

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
    
    *By doing this, I realized 
}


use "data/additional_processing/gmm_skills_dataset", clear

append using "data/additional_processing/gmm_employment_dataset"


merge m:1 occupation year using `job_filter', keep(3) nogen
merge m:1 occupation year using `employment_filter', keep(3) nogen 


drop if missing(y_var)

sort equation skill occupation  year   education    

tempvar temp
tempvar y_ref

generate `temp'=y_var if  skill==4 & equation==1

egen `y_ref'=max(`temp') if equation==1, by(occupation year education)

replace y_var=y_var-`y_ref' if equation==1

replace y_var=1 if equation==2

foreach variable in $index_list {
    replace `variable'=`variable'-$ref_skill_name
}

drop if skill==$ref_skill_num

cap drop `temp'
cap drop `y_ref'


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
*{

cap drop e1d_*

*Occupation dummies
{
    levelsof skill
    foreach skill in `r(levels)' {
            qui xi , prefix(e1s`skill') noomit i.occ_id*i.year_id
            cap drop e1s`skill'occ_id_*
            cap drop e1s`skill'year*
            foreach variable of varlist e1s`skill'* { 
                qui replace `variable'=0 if equation!=1 | skill!=`skill'
                qui replace `variable'=-1 if `variable'==1
                qui summ `variable'

                if `r(min)'==0 {
                    qui drop `variable'
                }

                cap rename `variable' `variable'_`skill'        
            }
        
    }
}


cap drop e2_index_*
foreach education in $educ_lev {
    local index_counter=1
    foreach index in $index_list {
        generate e2_index_`index_counter'_`education'=0
        qui replace e2_index_`index_counter'_`education'=`index' if equation==2 & education==`education'
        local ++index_counter
    }
}


cap drop e3_index_*
foreach education in $educ_lev {
    local index_counter=1
    foreach index in $index_list {
        generate e3n_index_`index_counter'_`education'=0
        qui replace e3n_index_`index_counter'_`education'=index`index_counter' if equation==3&education==`education'
        local ++index_counter
    }
}

cap drop e3d_index_*
foreach education in $educ_lev {
    local index_counter=1
    foreach index in $index_list {
        generate e3d_index_`index_counter'_`education'=0
        qui replace e3d_index_`index_counter'_`education'=index`index_counter' if equation==3&education_d==`education'
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

drop x_11 x_13

drop ee_group_id
egen ee_group_id=group(education education_d year)
order ee_group_id, after(education_d)


save "data/additional_processing/gmm_example_dataset", replace


egen ln_alpha=group(occupation skill year)
order ln_alpha, after(equation)
export delimited using  "data/additional_processing/gmm_example_dataset.csv", replace

