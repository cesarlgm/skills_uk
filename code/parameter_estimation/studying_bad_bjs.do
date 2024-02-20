
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

generate people=1/gwtall
*Collapsing at the occupation-education-year level
gcollapse (mean) $index_list *_i (sum) obs=people [fw=gwtall], by(occupation)
    
tempfile skill_use
save `skill_use'



import excel "data\output\b_estimates_eq6.xlsx", sheet("Sheet1") firstrow clear

generate wrong_b=estimate>0

tempfile bj_estimate
save `bj_estimate'


use "./data/temporary/LFS_industry_occ_file", clear

rename $occupation occupation
rename $education education 
gcollapse (sum) people (count) obs=people, by(occupation education)

egen t_employment=sum(people), by(occupation)

generate employment_share=people/t_employment

egen employment=sum(people)

generate overall_share=t_employment/employment

gegen o_employment=xtile(overall_share), nq(100)

gegen q_empshare=xtile(employment_share), nq(100) by(education)

keep occupation education employment_share q_empshare o_employment overall_share

reshape wide employment_share q_empshare , i(occupation) j(education)

merge 1:1 occupation using `bj_estimate', keep(3) nogen
merge 1:1 occupation using `skill_use', keep(3) nogen

br if wrong_b

gsort -estimate

table wrong_b, c(mean employment_share1 mean employment_share2 mean employment_share3)

table wrong_b, c(mean q_empshare1  mean q_empshare2 mean q_empshare3 mean overall_share )

table wrong_b, c(mean manual  mean social mean routine mean abstract_a2)

