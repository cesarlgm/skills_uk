*Creating the SES database

do "code/process_SES/save_file_for_minimization.do" $education
do "code/process_SES/compute_skill_indexes.do"

rename $education education
rename $occupation occupation

generate total_skill=.
forvalues education=1/4 {
    local equation ${c_manual`education'}*manual+${c_social`education'}*social+${c_routine`education'}*routine+${c_abstract`education'}*abstract
    replace total_skill=`equation' if education==`education'
}

forvalues education=1/4 {
    eststo reg`education': regress total_skill i.occupation if education==`education',
}

esttab reg1 reg2 reg3, drop(*) stat(F) mtitles(Low Mid High)

*Collapsing the dataset
gcollapse (mean) total_skill (count) obs=chands, by(occupation year education)
    