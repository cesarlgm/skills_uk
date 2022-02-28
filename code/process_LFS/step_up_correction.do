*This creates the dataset to do the step up correction for hypothesis testing


*Getting occupations that increased the low share
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

    generate threshold=.20*_n/_N

    generate reject=p_value<threshold

    rename p_value new_p_value

    merge m:1 $occupation using "data/additional_processing/file_step_up_correction"

    keep if reject&d_empshare1>0

    duplicates  drop $occupation, force

    log using "results/log_files/t_stats.txt", text replace
    list bsoc00Agg d_empshare1 t_stat threshold p_value empshare*
    log close
    /*
    keep $occupation
    save "data/additional_processing/increase_low_occupations", replace
    */
}
/*
*How do these occupations look in the skill space
{
    do "code/process_SES/save_file_for_minimization.do"
    drop if year==1997

    merge m:1 $occupation using  "data/additional_processing/increase_low_occupations", keep(1 3)

    gen interest_occ=_merge==3

    drop _merge

    local abstract 		cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
    local social		cpeople cteach  cspeech cpersuad cteamwk clisten
    local routine		brepeat bvariety cplanme bme4 
    local manual		chands cstrengt  cstamina
    global index_list 	abstract social routine manual 

    foreach index in $index_list {
        egen `index'=rowmean(``index'')
    }

    label define interest_occ 0 "All other" 1 "Increased low share"
    label values interest_occ interest_occ

    foreach index in $index_list {
        eststo `index'01: regress `index' ibn.interest_occ if year==2001, vce(cl $occupation) nocons
        eststo `index'17: regress `index' ibn.interest_occ if year==2017, vce(cl $occupation) nocons
        eststo `index'01d: regress `index' i.interest_occ if year==2001, vce(cl $occupation) 
        eststo `index'17d: regress `index' i.interest_occ if year==2017, vce(cl $occupation) 
        eststo `index'd: regress `index' i.year##i.interest_occ, vce(cl $occupation)
    }

    local table_name "results/tables/up_low_occ.tex"
    local table_title "Skill use in occupations with increased low share"
    local coltitles 2001 2017
    *None of the over time differences are significant
    textablehead using `table_name', ncols(2) coltitles(`coltitles') title(`table_title') drop
    foreach index in $index_list {
        writebf using `table_name', text(`index')
        leanesttab `index'01 `index'17 using `table_name', not append noobs nostar
        leanesttab `index'01d `index'17d using `table_name', keep(1.interest_occ) coeflabel(1.interest_occ "Difference")  append noobs nostar
    
    }
    textablefoot using `table_name'
}