

*Output dataset with employment shares
{
    frames reset
    
    use "data/additional_processing/t_tests", clear

    merge m:1 occupation year using  "data/additional_processing/survived_BKY", keep(1 3)
    
    
    generate deskilled=t_stat_mean>0
    cap drop _merge


    
    *generate deskilling=(d_empshare1*2-d_empshare2-d_empshare3)/(sqrt(d_empshare1^2+d_empshare2^2+d_empshare3^2)*sqrt(6))

    *generate angle=acos(deskilling)
    
    export delimited using "data/additional_processing/empshares_graphs.csv", replace

    /*
    bysort $occupation: keep if _n==1
    keep if deskilled>0
    gsort d_empshare1

    log using "results/log_files/deskilling_occupations.txt", replace text
    unique $occupation
    list bsoc00Agg empshare1 d_empshare1
    log close
    */
}
