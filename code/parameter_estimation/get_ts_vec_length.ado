cap program drop get_ts_vec_length

program define get_ts_vec_length, rclass
    foreach educ in $educ_lev {
        qui ds ts_*`educ'_*
        local length`educ': word count of  `r(varlist)'
        return scalar length`educ'= `length`educ''-1
    }
end