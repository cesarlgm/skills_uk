
frames reset
*Computing indexes
{
    do "code/process_SES/save_file_for_minimization.do" $education
    do "code/process_SES/compute_skill_indexes.do"

    rename $education education
    rename $occupation occupation

    levelsof education
    global n_educ: word count of `r(levels)'
    global n_educ=$n_educ-1
}

drop if year==1997

*Collapsing at the occupation-education-year level
gcollapse (mean) $index_list *_i (count) obs=chands, by(occupation year education)
    
*Uncomment this to do long differences
*keep if  inlist(year,2001,2017)

*Setting panel dataset
{
    egen group_id=group(occupation education)
    egen time=group(year)

    xtset group_id time
}

*Creating log and dlog of skills
foreach index in $index_list {
    rename `index'_i l_`index'
    generate d_l_`index'=d.l_`index'
}

foreach index in $index_list {
    label var l_`index' "Average log(`index')"
    label var `index'   "Average `index'"
}

drop if year==2001

frames copy default equation1
frames change equation1
*Creating equation 1 dataset
{
    local counter=1
    foreach index in $index_list {
        preserve  
        keep year education occupation l_`index' $index_list
        rename l_`index' y_var
        generate skill=`counter'
        tempfile skill`counter'
        save `skill`counter''
        local ++counter
        restore
    }
    clear
    forvalues i=1/4 {
        append using `skill`i''
    }
    label define skill 1 "manual" 2 "social" 3 "routine" 4 "abstract"
    label values skill skill

    generate equation=1

    *This finishes first part of the dataset.
    tempfile equation1
    save `equation1'
}

*Creating equation 2 dataset
{
    frames change default
    local counter=1
    foreach index in $index_list {
        preserve
        generate a_`index'=d_l_`index'-d_l_$reference
        keep a_`index' occupation education year
        rename a_`index' y_var
        generate skill=`counter'
        tempfile a_dataset`counter'
        generate equation=2
        save `a_dataset`counter''
        restore
        local ++counter
    }

    clear
    forvalues counter=1/4{ 
        append using `a_dataset`counter''
    }
    tempfile equation2
    save `equation2'
}

clear 
append using `equation1'
append using `equation2'

save "data/additional_processing/gmm_skills_dataset", replace