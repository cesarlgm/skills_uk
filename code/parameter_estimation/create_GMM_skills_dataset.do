
global index_list manual social routine abstract`1'
global n_skills: word count $index_list



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

pwcorr $abstract

*Collapsing at the occupation-education-year level
gcollapse (mean) $index_list *_i (count) obs=chands [fw=gwtall], by(occupation year education)
    


frames copy default equation1
frames change equation1


*Creating equation 1 dataset
{
    local counter=1
    foreach index in $index_list {
        preserve  
        keep year education occupation `index' $index_list *_i  obs
        generate  y_var=`index'_i
        generate skill=`counter'
        tempfile skill`counter'
        save `skill`counter''
        local ++counter
        restore
    }

    clear
    forvalues i=1/$n_skills {
        append using `skill`i''
    }
    
    label define skill 1 "manual" 2 "social" 3 "routine" 4 "abstract"
    label values skill skill

    generate equation=1

    *This finishes first part of the dataset.
    tempfile equation1
    save `equation1'
}

clear 
append using `equation1'

preserve 
    replace y_var=1
    replace equation=2
    duplicates drop occupation education year, force
    tempfile total_skill
    save `total_skill'
restore 
append using `total_skill'

label define equation 1 "Skills equation" 2 "Total sum of skills restriction" 3 "Employment equation"
label values equation equation

generate temp=1 if equation==1
egen in_eqn_1=max(temp), by(occupation)
drop if missing(in_eqn_1)|in_eqn_1==0

drop temp

save "data/additional_processing/gmm_skills_dataset`1'", replace



