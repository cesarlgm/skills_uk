  forvalues j=2/4 {
            append using "data/temporary/LFS2001q`j'_indiv", force
        }

        forvalues j=1/4 {
            append using "data/temporary/LFS2017q`j'_indiv", force
        }
