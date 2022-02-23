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

    replace observations=floor(observations)

    generate low_education=$education==1

    levelsof $occupation 
    
    cap drop p_value
    generate p_value=.
    foreach occupation in `r(levels)' {
        tab low_education year if $occupation==`occupation' [fw=observation], chi
        replace p_value=`r(p)' if `occupation'==$occupation
    }

    keep $occupation p_value

    gsort p_value

    generate threshold=.2*_n/_N

    generate reject=p_value<threshold

    rename p_value new_p_value

    merge m:1 $occupation using "data/additional_processing/file_step_up_correction"

    keep if reject&d_empshare1>0

    /*
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

    drop empshare2 empshare3 observations2 observations3 
    reshape wide empshare1 observations1 occ_obs, i($occupation) j(year)
    *Compute t-statistic

    generate df=occ_obs2001+occ_obs2017-2
    generate sp=((occ_obs2001-1)*empshare12001*(1-empshare12001)+(occ_obs2017-1)*empshare12017*(1-empshare12017))/(df)
    generate t_stat=d_empshare1/sqrt(sp/(occ_obs2001-1)+sp/(occ_obs2017-1))

    generate p_value=ttail(df,t_stat)

    gsort p_value
    
    generate threshold=.1*_n/_N

    generate reject=p_value<threshold

    log using "results/log_files/t_stats.txt", text replace
    list bsoc00Agg d_empshare1 t_stat threshold p_value
    log close

    save "data/additional_processing/file_step_up_correction", replace
    */
}