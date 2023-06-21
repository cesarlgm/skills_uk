*===============================================================================
*CREATING TRIANGLE ARROW GRAPH
*Author: César Garro-Marín
*===============================================================================

*Output dataset with employment shares
{
    frames reset
    
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
    *The chunck of code restricts the samp`le to only those that appear in the SES
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

    *Compute changes in employment shares between 2001 and 2017
    sort $occupation year
    foreach variable of varlist empshare* {
        by  $occupation: generate temp=`variable'-`variable'[_n-1] 
        egen d_`variable'=max(temp), by($occupation)
        cap drop temp
    }
    
    merge m:1 $occupation using  "data/additional_processing/increase_low_occupations_all", keep(1 3)
    generate deskilled=_merge==3
    cap drop _merge

    merge m:1 $occupation using  "data/additional_processing/increase_low_occupations", keep(1 3)
    generate survived=_merge==3
    cap drop _merge


    *generate deskilling=(d_empshare1*2-d_empshare2-d_empshare3)/(sqrt(d_empshare1^2+d_empshare2^2+d_empshare3^2)*sqrt(6))

    *generate angle=acos(deskilling)
    

    export delimited using "data/additional_processing/empshares_graphs.csv", replace

    bysort $occupation: keep if _n==1
    keep if deskilled>0
    gsort d_empshare1

    log using "results/log_files/deskilling_occupations.txt", replace text
    unique $occupation
    list bsoc00Agg empshare1 d_empshare1
    log close
}
/*
*Creating the graph in R
rscript using "code/process_SES/create_direction_graph.R"
