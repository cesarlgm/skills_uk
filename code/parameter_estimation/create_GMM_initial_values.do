*Compute GMM initial values
global n_skills=4
global ref_skill_num    4
global ref_skill_name   abstract
global not_reference    manual


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


        *keep if inlist(occupation, 1112,1121,1122)

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

    save "data/additional_processing/gmm_initial_dataset", replace
}

*Part 1: compute pi_ijt
{
    use "data/additional_processing/gmm_initial_dataset", clear

    cap drop _*
    cap drop `y_ref'

    tempvar temp
    tempvar y_ref

    generate `temp'=y_var if  skill==4 & equation==1

    egen `y_ref'=max(`temp') if equation==1, by(occupation year education)

    replace y_var=y_var-`y_ref' if equation==1

    replace y_var=1 if equation==2

    foreach variable in $index_list {
        replace `variable'=`variable'-$ref_skill_name if equation==1
    }

    cap drop `temp'
    cap drop `y_ref'



    local lbe : value label education

    levelsof education
    global n_educ: word count of `r(levels)'
    global n_educ=$n_educ-1
    keep if equation==1

    *Computing weights

    *To do later: find the appropriate weight for the estimates

    *For now they go as a simple averages. Ask Kevin what the appropriate weights should be.
    egen pi=mean(y_var) if !missing(y_var), by(occupation year skill)

    keep occupation year skill pi
    duplicates drop

    drop if missing(pi)

    tempfile pi_employment
    save `pi_employment'

    reshape wide pi, i(occupation year) j(skill)

    rename pi1 pi_manual
    rename pi2 pi_social
    rename pi3 pi_routine
    rename pi4 pi_abstract

    tempfile pi_file
    save `pi_file'
}

*Part 2: compute thetas
{
    {
        use "data/additional_processing/gmm_skills_dataset", clear
        keep if equation==1

        merge m:1 occupation year using `pi_file', keep(3) nogen 

        foreach index in $index_list {
            generate x_`index'=`index'*pi_`index'
        }

        generate y_var_init=.
        forvalues skill=1/4 {
            local index: word `skill' of $index_list 
            replace y_var_init=y_var+pi_`index' if skill==`skill'
        }

        eststo clear
        
        *Computing and extracting the thetas
        {
            eststo reg: regress y_var_init ibn.education#c.x_* , nocons

            generate skill_sum=. 
            forvalues education=1/$n_educ {
                local social`education'=            _b[`education'.education#c.x_social]
                local $not_reference`education'=     _b[`education'.education#c.x_$not_reference]
                local routine`education'=           _b[`education'.education#c.x_routine]
                replace skill_sum=_b[`education'.education#c.x_social]*social+_b[`education'.education#c.x_abstract]*abstract+_b[`education'.education#c.x_routine]*routine if education==`education'
            }
            generate y_skill_sum=1-skill_sum
        
            eststo $ref_skill_name: regress y_skill_sum ibn.education#c.$ref_skill_name $weight if skill==1 , nocons vce(cl occupation)
            forvalues education=1/$n_educ{
                local  $ref_skill_name`education'= _b[`education'.education#c.$ref_skill_name]
            }
        }
        
        clear
        local n_obs=$n_educ*$n_skills
        di `n_obs'
        set obs `n_obs'

        local counter=1
        generate education=.
        generate skill=.
        generate parameter=.
        forvalues educ=1/$n_educ {
            forvalues skill=1/$n_skills {
                replace education=`educ' if _n==`counter'
                replace skill=`skill' if _n==`counter'
                local skill_name: word `skill' of $index_list 
                replace parameter=``skill_name'`educ'' if _n==`counter'
                local ++counter
            }
        }
    } 

    label define skill 1 "manual" 2 "social" 3 "routine" 4 "abstract"
    label values skill skill
    label var education "`lbe'"

    generate source_name="theta"

    tempfile theta_file
    save `theta_file'
}

*Create the file with the initial values
{
    use `pi_file', clear
    local counter=1
    foreach index in $index_list {
        rename pi_`index' pi`counter'
        local ++counter
    }
    reshape long pi, i(occupation year) j(skill)
    rename pi parameter

    generate source_name="pi_ij"

    sort occupation year skill

    append using `theta_file'

    generate identifier=""
    foreach variable in occupation year skill education {
        tostring `variable', replace force
    }
    replace  identifier=occupation+"."+year+"."+skill   if source_name=="pi_ij"
    replace  identifier=education+"."+skill             if source_name=="theta"

    drop if skill=="4" & source_name=="pi_ij"
    *Drop this is parameters are not restricted

    generate param_number=_n
    replace param_number=_n-3000 if source_name=="theta"
    sort param_number

    keep source_name parameter identifier
    generate parameter_id=_n

    replace parameter=0.01 if parameter<0&source_name=="theta"

    save "data/additional_processing/initial_values_file", replace
    export delimited using  "data/additional_processing/initial_estimates.csv", replace

}