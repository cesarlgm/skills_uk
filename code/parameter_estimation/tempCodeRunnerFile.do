    foreach variable of varlist o_* {
        replace `variable'=0 if missing(`variable')
    }
