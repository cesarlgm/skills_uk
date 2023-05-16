
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
