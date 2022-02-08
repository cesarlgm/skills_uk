*================================================================
*This codes generates all the data that I am using for estimation
*of the model parameters.
*================================================================

*Filters in the data:
* - I use only observation from core jobs.
* - As it stands right now, I am using observations of core jobs.
* - However, I am using observations of all education groups.

*Things to remember:
*These regressions only use data from core jobs

frame reset
local occupation bsoc00Agg
local definition_list  educ_3_low //educ_4  educ_3_mid
foreach definition in `definition_list' { 
    use "./data/temporary/LFS_industry_occ_file", clear


    *In this chunk of code I create the variables I need for panel data operations.
    {

        gcollapse (sum) people, by(`occupation' industry_cw year `definition')

        egen obs_id=group(`definition' `occupation' industry_cw)

        egen time_id=group(year)
    
        xtset obs_id time_id   
    }   


    *Here I add information from the job classification
    merge m:1 `occupation' year using  "data/temporary/job_classification_`definition'", ///
        keep(1 3) keepusing(ref_job_type0) nogen 

    *What definition was this?
    drop if missing(ref_job_type0)

    generate core_job=inlist(ref_job_type0,1,2,3)

    sort obs_id time_id
    
    *At this point I have:
        *Classiffied the jobs.
        *And I identified which jobs are core jobs

    *Here I drop all of the jobs for which I don't have data in the SES

    *The chunck of code below gets the occupations that are in SES
    {
        frame create SES_occs
        frame change SES_occs
        do "code/process_SES/save_file_for_minimization.do"
        
        tempfile SES_file
        save `SES_file'

        keep bsoc00Agg `education' year 
        duplicates drop 


        tempfile SES_occs
        save `SES_occs'
    }


    frame change default
    merge m:1 bsoc00Agg year using `SES_occs', keep(1 3) 

    *This line drops any occupation for which I don't have data in SES.
    drop if _merge!=3

    sort obs_id time_id 

    *=======================================================================
    *Now: I get those jobs that stay as core jobs in two consecutive years
    *=======================================================================
    {    
        *Indicator of whether the job stays in the sample classification for two consecutive waves
        generate same_classification=ref_job_type0==l.ref_job_type0

        log using "results/log_files/jobs_in_same_classification.txt", replace text
            di "Share of core jobs that do not chage classification in consecutive waves, by type of core type job"
            table ref_job_type0 if core_job&educ_3_low==ref_job_type0, c(mean same_classification) 
        log close
  
        *I restrict observations to core jobs that stay in the core for two consecutive waves
        keep if (same_classification&ref_job_type0==`definition')| ///
            (core_job&year==2001&f.same_classification==1&ref_job_type0==`definition')
    }

    
    *Computing changes in employment shares and total emploument

    {
        generate l_employment=log(people)

        generate d_l_employment=l_employment-l.l_employment

        egen total_educ=sum(people), by(year `definition')

        generate educ_empshare=people/total_educ

        generate l_educ_empshare=log(educ_empshare)

        generate d_l_educ_empshare=d.l_educ_empshare

        generate ref_year=l.year

        drop if missing(d_l_educ_empshare)

        keep bsoc00Agg ref_year ref_job_type0 d_l_educ_empshare d_l_employment industry_cw

        sort  ref_job_type0 ref_year d_l_educ_empshare

        rename ref_year year
    }

    *At this point I have computed the changes in the log of employment share across occupation.
    *What do I do next?
    *   - I make sure that I will have the same set of jobs in both the SES and the LFS
    {
        preserve
            rename bsoc00Agg occupation
            rename ref_job_type0 education

            tempfile lfs_to_filter
            save `lfs_to_filter'    
        restore

        *I get the set of years, occupations and education levels
        {
            keep ref_job_type0 year bsoc00Agg

            duplicates drop 

            rename ref_job_type0 `definition'

            tempfile filter_SES
            save `filter_SES'
        }    
    

        use `SES_file', clear 
        merge m:1 bsoc00Agg `definition' year using `filter_SES', keep(3) nogen 

        rename bsoc00Agg occupation
        rename `definition' education

        export delimited "data/additional_processing/SES_file_theta_estimation.csv", ///
            replace nolabel 
        save "data/additional_processing/final_SES_file.dta", replace
    }
    *At this point I have saved the final SES file. I use the occupations in this final ses file to filter again the changes in employment.


    *In this code I apply the final filter to the LFS
    {
        keep occupation education year
        duplicates drop 
        tempfile to_filter_LFS
        save `to_filter_LFS'


        {
            use `lfs_to_filter', clear
            merge m:1 occupation education year using `to_filter_LFS', keep(3) nogen 
            
            export delimited "data/additional_processing/LFS_file_theta_estimation.csv", ///
                replace nolabel 

            save "data/additional_processing/final_LFS_file.dta", replace
        }
    }

}