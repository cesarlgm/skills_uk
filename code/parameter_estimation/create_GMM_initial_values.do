*Compute GMM initial values
global n_skills=4

*Part 1: compute pi_ijt
{
    use "data/additional_processing/gmm_skills_dataset", clear

    local lbe : value label education

    levelsof education
    global n_educ: word count of `r(levels)'
    global n_educ=$n_educ-1
    keep if equation==2

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
        
            eststo $reference: regress y_skill_sum ibn.education#c.$reference if skill==1 $weight, nocons vce(cl occupation)
            forvalues education=1/$n_educ{
                local  $reference`education'= _b[`education'.education#c.$reference]
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



*Part 3: compute the beta_j

*Some preliminary details
{
    *Fixing thetas
    {
        use `theta_file', clear
        rename education education_d
        rename parameter parameter_d
        tempfile theta_file_d
        save `theta_file_d'
    }
}

{
    use  "data/additional_processing/gmm_employment_dataset", clear
    reshape long index indexd, i(occupation education education_d year)  j(skill)

    merge m:1 education skill using `theta_file', keep(3) nogen
    merge m:1 education_d skill using `theta_file_d', keep(3) nogen
    merge m:1 occupation skill year using `pi_employment', keep(3) nogen

    generate x_skill=(parameter*index-parameter_d*indexd)*pi
    
    keep occupation education education_d year skill y_var x_skill
    reshape wide x_skill, i(occupation education education_d year) j(skill)

    egen x_var=rowtotal(x_*)
    egen pair_id=group(education education_d)

    reghdfe y_var ibn.occupation#c.x_var, absorb(pair_id) nocons

    regsave

    generate sigma_j=1/(1-coef)

    extcodes, coefname(occupation)

    rename coef beta_j
    keep occupation beta_j sigma_j

    sort occupation

    rename beta_j parameter 
    
    generate source_name="beta"

    tempfile beta_file
    save `beta_file'
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

    generate source_name="pi"

    sort occupation year skill
    append using `theta_file'
    append using `beta_file'
    generate parameter_no=_n

    save "data/additional_processing/initial_values_file_key", replace

    keep parameter parameter_no source_name

    save "data/additional_processing/initial_values_file", replace
}