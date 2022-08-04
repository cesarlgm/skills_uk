*Compute GMM initial values
global n_skills=4
global ref_skill_num    4
global ref_skill_name   abstract
global not_reference    manual

*Part 1: compute pi_ijt
{
    use "data/additional_processing/gmm_example_dataset", clear

    
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


    generate param_number=_n
    replace param_number=_n-3000 if source_name=="theta"
    sort param_number
    
    keep source_name parameter identifier
    generate parameter_id=_n

    save "data/additional_processing/initial_values_file", replace
    export delimited using  "data/additional_processing/initial_estimates.csv", replace

}