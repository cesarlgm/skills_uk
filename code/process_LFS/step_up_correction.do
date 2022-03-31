*This creates the dataset to do the step up correction for hypothesis testing


*Getting occupations that increased the low share
{
    frames reset
    global education educ_3_low
    global occupation bsoc00Agg

    use "./data/temporary/LFS_industry_occ_file", clear


    tab educ_3_low year if inlist(year, 2001,2017) [aw=people], col nofreq

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
    

    cap drop p_value*
    foreach educ in 1 2 3 {
        generate p_value`educ'=.
        generate educ_level=$education==`educ'
        levelsof $occupation 
        foreach occupation in `r(levels)' {
            di `occupation'
            cap tab educ_level year if $occupation==`occupation' [fw=observation], chi
            cap replace p_value`educ'=`r(p)' if $occupation==`occupation'
        }
        cap drop educ_level
    }


    keep $occupation p_value*
    duplicates drop 

    merge m:1 $occupation using "data/additional_processing/file_step_up_correction", keepusing(d_empshare*)
    
    duplicates  drop $occupation, force
    
    forvalues educ=1/3 {
        gsort p_value`educ'
        generate threshold`educ'=.20*_n/_N
        generate reject`educ'=p_value`educ'<threshold`educ'
    }
    
    log using "results/log_files/t_stats_1.txt", text replace
    list bsoc00Agg d_empshare1 d_empshare2 d_empshare3  threshold1 p_value1  if reject1&d_empshare1>0
    log close
    
    log using "results/log_files/t_stats_3.txt", text replace
    list bsoc00Agg d_empshare3  threshold3 p_value3 if reject3&d_empshare3<0
    log close

        
    log using "results/log_files/t_stats_2.txt", text replace
    list bsoc00Agg d_empshare2  threshold2 p_value2 if reject2&d_empshare2<0
    log close 

    expand 2
    eststo clear
    foreach variable of varlist d_empshare* {
        eststo `variable': regress `variable' ibn.bsoc00Agg if reject1&d_empshare1>0, nocons
    }

    local table_name "results/tables/polarizing_occupations.tex"
    local table_title "Polarizing occupations: change in occupational employment shares by education group, 2001-2017"
    local coltitles `""Low""Mid""High""'
    local table_notes "the table shows the 9 occupations (i) where the low education share increased, and (ii) survived the Benjamini-Hochberg step up procedure for the test of no change in the low education employment share at 20\% significance level"

    textablehead using `table_name', f(Occupation) ncols(3) title(`table_title') coltitles(`coltitles')
    esttab d_empshare1 d_empshare2 d_empshare3  using `table_name', f b(2) append booktabs label not noobs nomtitles plain collabels(none)
    textablefoot using `table_name', notes(`table_notes')

    keep bsoc00Agg
    duplicates drop
    save "data/additional_processing/increase_low_occupations", replace
}

*Is the employment share in these 9 occupation disappearing?
{
    frames reset
    global education educ_3_low
    global occupation bsoc00Agg

    use "./data/temporary/LFS_industry_occ_file", clear

    merge m:1 $occupation using  "data/additional_processing/increase_low_occupations", keep(1 3)

    generate deskilled=_merge==3

    cap drop _merge

    eststo share_change: regress deskilled ibn.year [aw=people], nocons 

    
    grscheme, ncolor(7) style(tableau)
    coefplot, base vert yscale(range(0 .05)) ///
        ylab(0(.01).05) xlab(1 "2001" 2 "2006" 3 "2012" 4 "2017")
    graph export "results/figures/empshare_in_polarizing_occupations.png", replace

    local figure_name "results/figures/empshare_in_polarizing_occupations.tex"
    local path "../results/figures/"
    local figure_list empshare_in_polarizing_occupations.png
    local figure_title "Overall employment share in polarizing occupations"
    local figure_note "the figure shows the overall employment share for nine polarizing occupations"
    local figure_key "fig:empshare_coef"

    latexfigure using `figure_name', ///
        path(`path') rowsize(2) note(`figure_note') ///
        figurelist(`figure_list') title(`figure_title')
    


    /*
    local table_name "results/tables/overall_employment_share_deskill.tex"
    local table_title "Employment share of deskilling occupations by year"
    local coltitles `""Employment share""'

    textablehead using `table_name', ncols(2) coltitles(`coltitles') title(`table_title') drop
    leanesttab share_change using `table_name', append nostar fmt(3)
    textablefoot using `table_name'

    generate high_educ= $education==3
    generate mid_educ=  $education==2
    generate low_educ=  $education==1


    eststo high:    regress high ibn.year [aw=people] if deskilled, nocons
    eststo mid:     regress mid ibn.year [aw=people] if deskilled, nocons
    eststo low:     regress low ibn.year [aw=people] if deskilled, nocons

    local table_name "results/tables/deskilling_occ_educ_shares.tex"
    local table_title "Education employment share of deskilling occupations by year"
    local coltitles `""Low""Mid""High""'

    textablehead using `table_name', ncols(3) coltitles(`coltitles') title(`table_title') drop
    leanesttab low mid high using `table_name', append nostar fmt(3)
    textablefoot using `table_name'

    eststo low:         reghdfe low i.year [aw=people] if deskilled, nocons absorb($occupation)
    eststo mid:         reghdfe mid i.year [aw=people] if deskilled, nocons absorb($occupation)
    eststo high:        reghdfe high i.year [aw=people] if deskilled, nocons absorb($occupation)

    local table_name "results/tables/deskilling_occ_educ_shares_fe.tex"
    local table_title "Education employment share of deskilling occupations by year, includes occ fe"
    local coltitles `""Low""Mid""High""'
    
    textablehead using `table_name', ncols(3) coltitles(`coltitles') title(`table_title') drop
    leanesttab low mid high using `table_name', append nostar fmt(3)
    textablefoot using `table_name'
    */
}


/*
*How do these occupations look in the skill space
{
    do "code/process_SES/save_file_for_minimization.do"

    keep if educ_3_low==1

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

