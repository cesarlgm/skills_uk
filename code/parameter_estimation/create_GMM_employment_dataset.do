*Create GMM employment dataset
*I prepare skill part of the data
{
    { 
        use  "data/additional_processing/gmm_skills_dataset", clear
        keep if skill==1&equation==1
        drop equation y_var skill
        tempfile numerator
        save `numerator'
    }

    {
        use  "data/additional_processing/gmm_skills_dataset", clear
        keep if skill==1&equation==1
        drop equation y_var skill
        rename education education_d
        
        foreach skill in $index_list {
            rename `skill' `skill'_d
        }
        
        tempfile denominator_s
        save `denominator_s'   
    }
}

{
    use "./data/temporary/LFS_industry_occ_file", clear

    rename $occupation occupation
    rename $education education 
    gcollapse (sum) people (count) obs=people, by(occupation  year education)

    preserve
    drop obs 
    rename people people_d
    rename education denominator
    tempfile denominator
    save `denominator'
    restore

    generate denominator=.
    replace denominator=3 if education==1
    replace denominator=2 if education==3
    replace denominator=1 if education==2

    merge 1:1 year denominator occupation using `denominator', keep(3) nogen

    label values denominator $education

    generate y_var=log(people/people_d)

    rename denominator education_d

    order occupation education education_d year
    keep occupation education education_d year y_var

    generate equation=3

    *Now I add skill information
    merge 1:1 occupation year education  using `numerator', nogen keep(3)

    merge 1:1 occupation year education_d using `denominator_s', nogen  keep(3)

    local counter=1
    foreach skill in $index_list {
        rename `skill' index`counter'
        rename `skill'_d indexd`counter'
        local ++counter
    }

    egen  n_pair=count(education), by(occupation year)
    order n_pair, after(education_d)

    *This drops the pair that is redundant
    drop if education==1&education_d==3&n_pair==3

    drop n_pair

    save "data/additional_processing/gmm_employment_dataset", replace
}
