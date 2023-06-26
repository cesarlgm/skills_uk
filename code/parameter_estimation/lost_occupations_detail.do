
/*Analysis of occupation filters*/


*Getting the filter for the 2 equation solution
{
    use  "data/additional_processing/gmm_skills_dataset", clear

    keep if equation==1

    generate mis_y_var=missing(y_var)

    cap drop temp
    gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
    egen n_educ=max(temp), by(occupation year)

    preserve
        keep if n_educ==3
        keep occupation
        unique occupation 
        generate in_panel=1
        duplicates drop
        tempfile kept_occ
        save `kept_occ'
    restore

}

*======================================================================================================
*SES DATA
*======================================================================================================

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

merge m:1 occupation using `kept_occ', keep(3)

preserve
    gcollapse (sum) gwtall, by(education year) fast 

    *TABLE WITH THE FREQUENCES BY EDUCATION LEVEL
    tab education year [fw=gwtall]
restore 

merge m:1 occupation using "data/additional_processing/GMM_occupation_filter", nogen keep(3)

gcollapse (sum) gwtall, by(education year) fast 

*TABLE WITH THE FREQUENCES BY EDUCATION LEVEL
tab education year [fw=gwtall]


*======================================================================================================
*LFS DATA
*======================================================================================================

use "./data/temporary/LFS_agg_database", clear

do "code/process_LFS/create_education_variables.do"

rename $occupation occupation
rename $education education

preserve
    gcollapse (sum) people, by(education year)

    tab education year [fw=people] if inlist(year,2001,2006,2012,2017)
restore 



merge m:1 occupation using `kept_occ', keep(3)

preserve
    gcollapse (sum) people, by(education year)

    tab education year [fw=people] if inlist(year,2001,2006,2012,2017)
restore 

merge m:1 occupation using "data/additional_processing/GMM_occupation_filter", nogen keep(3)

gcollapse (sum) people, by(education year)

tab education year [fw=people] if inlist(year,2001,2006,2012,2017)




/*

/*
replace in_panel=0 if missing(in_panel)

drop if mis_y_var

keep if skill==1


egen occ_empl=sum(obs), by(occupation year)

generate educ_share=obs/occ_empl

generate temp_educ=education==3
generate temp_educ2=temp_educ*educ_share
egen high_occ=max(temp_educ2), by(occupation)

keep if !in_panel

keep occupation high_occ
duplicates drop 

/*


table education year if in_panel, c(mean educ_share)

table education year if !in_panel, c(mean educ_share)

