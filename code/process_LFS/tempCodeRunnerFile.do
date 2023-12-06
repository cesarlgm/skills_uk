        forvalues j=2/4 {
            append using "data/temporary/LFS2001q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2002q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2003q`j'_indiv", force
        }
        forvalues j=2/4 {
            append using "data/temporary/LFS2004q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2005q`j'_indiv", force
        }



        forvalues j=1/4 {
            append using "data/temporary/LFS2015q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2016q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2017q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2018q`j'_indiv", force
        }
        forvalues j=1/4 {
            append using "data/temporary/LFS2019q`j'_indiv", force
        }

        keep occupation year edlevLFS svy_weight
        replace year=2001 if inrange(year,2001,2005)
        replace year=2017 if inrange(year,2015,2023)

