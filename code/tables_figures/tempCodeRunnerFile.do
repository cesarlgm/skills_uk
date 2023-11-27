    frames reset
    
    use "data/additional_processing/t_tests", clear

    merge m:1 occupation year using  "data/additional_processing/survived_BKY", keep(1 3)
    