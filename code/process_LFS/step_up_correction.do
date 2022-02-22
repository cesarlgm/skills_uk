*This creates the dataset to do the step up correction for hypothesis testing

{
    frames reset
    global education educ_3_low
    global occupation bsoc00Agg

    use "./data/temporary/LFS_industry_occ_file", clear


    gcollapse (sum) people obs, by($occupation  year $education)

    egen total_people=sum(people), by(year $occupation)

    generate empshare=people/total_people
    egen    occ_obs=sum(obs), by($occupation year)

    keep $occupation $education year empshare  *obs obs

    keep if inlist(year, 2001,2017)

    
    *FILTERING OCCUPATIONS
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
    merge m:1 bsoc00Agg year using `SES_occs', keep(3) nogen

    
    
    reshape wide empshare obs, i($occupation year) j($education)
    
    sort $occupation year
    foreach variable of varlist empshare* {
        replace `variable'=0 if missing(`variable')
    }


    sort $occupation year
    foreach variable of varlist empshare* {
        by  $occupation: generate temp=`variable'-`variable'[_n-1] 
        egen d_`variable'=max(temp), by($occupation)
        cap drop temp
    }

    generate low_increase=d_empshare1>0

    order occ_obs observations*, last

    label define low_increase 1 "Low education share increases" 0 "Low education share decreases"
    label values low_increase low_increase


    summ occ_obs if low_increase, d

    save "data/additional_processing/file_step_up_correction", replace
}