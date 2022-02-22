

*CREATING TRIANGLE GRAPH
{
    {
        frames reset
        global education educ_3_low
        global occupation bsoc00Agg

        use "./data/temporary/LFS_industry_occ_file", clear


        gcollapse (sum) people, by($occupation  year $education)

        egen total_people=sum(people), by(year $occupation)

        generate empshare=people/total_people

        keep $occupation $education year empshare 

        reshape wide empshare, i($occupation year) j($education)

        foreach variable of varlist empshare* {
            replace `variable'=0 if missing(`variable')
        }

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



        keep if inlist(year, 2001, 2017)

        sort $occupation year
        foreach variable of varlist empshare* {
            by  $occupation: generate temp=`variable'-`variable'[_n-1] 
            egen d_`variable'=max(temp), by($occupation)
            cap drop temp
        }

        generate deskilling=(d_empshare1*2-d_empshare2-d_empshare3)/(sqrt(d_empshare1^2+d_empshare2^2+d_empshare3^2)*sqrt(6))

        generate angle=acos(deskilling)
        

        export delimited using "data/additional_processing/empshares_graphs.csv", replace

        bysort $occupation: keep if _n==1
        keep if deskilling>0
        gsort d_empshare1

        log using "results/log_files/deskilling_occupations.txt", replace text
        unique $occupation
        list bsoc00Agg empshare1 d_empshare1
        log close
    }


    *CREATING THE GRAPH
    *rscript using "code/process_SES/create_direction_graph.R"

    tempfile LFS_file
    save `LFS_file'
}

/*
*CREATING BORDER TRIANGLES
{
    
    use "data/temporary/filtered_dems_SES", clear

    replace cplanoth=6-cplanoth

    rename edlev edlevLFS
    do "code/process_LFS/create_education_variables.do"


    do "code/aggregate_SOC2000.do"

    merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

    keep if  n_years==4


    order 	year crosspid emptype edlev sex age bsoc2000 bsoc2010 ///
		isco88 b_soc90 bsoc00Agg  gwtall dpaidwk country ///
		region, before(bchoice)


    *First I compute the skill indexes
    {
        local abstract 		cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
        local social		cpeople cteach  cspeech cpersuad cteamwk clisten
        local routine		brepeat bvariety cplanme bme4 
        local manual		chands cstrengt  cstamina
        local list1         manual abstract routine
        local list2         manual abstract social
        local list3         manual social routine
        local list4         social abstract routine
        global index_list 	manual abstract social routine  

        local variable_list  `manual' `routine' `abstract' `social' 

        foreach variable in `variable_list' {
            summ `variable'
            replace `variable'=(`variable'-`r(min)')/(`r(max)'-`r(min)')
            summ `variable'
            assert `r(min)'==0
            assert `r(max)'==1
        }


        foreach index in $index_list {
            egen `index'=rowmean(``index'')
        }

        gcollapse (mean) $index_list (count) obs=chands, by($occupation year)
        
        tempfile indexes
        save `indexes'
    }
    
    use `LFS_file', clear
    merge m:1 $occupation year using `indexes' , keep(3) nogen

    
    forvalues j=1/4 {
        preserve
        egen total=rowtotal(`list`j'')
        foreach skill in `list`j''{
            replace `skill'=`skill'/total
        }
        keep $occupation year empshare* `list`j'' obs

        generate empshare12=empshare2/(empshare2+empshare1)
        generate empshare23=empshare3/(empshare2+empshare3)
        generate empshare13=empshare3/(empshare3+empshare1)
        
        export delimited using "data/additional_processing/skill_triangle_graphs`j'.csv", replace
        restore
    }
}

rscript using "code/process_SES/create_border_triangles.R"
