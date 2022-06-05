capture program drop count_parameters

program define count_parameters, rclass 
    version 14.2

    qui unique(education) if  !missing(y_var)&equation==1
    local n_educ=`r(unique)'


    qui unique(occupation) if !missing(y_var)&equation==1
    local n_sigma_j=`r(unique)'

    local n_skills: word count $index_list
    qui unique education if !missing(y_var)&equation==1
    local n_educ `r(unique)'
    local n_theta=`n_educ'*`n_skills'

    tempvar d_ln_A
    egen `d_ln_A'=group(occupation year skill) if equation==1
    qui unique `d_ln_A'  if equation==1
    local n_d_ln_A=`r(unique)'
    local ds_d_ln_A= `n_d_ln_A'/4*3

    return scalar n_skills=4
    return scalar n_sigma_j=    `n_sigma_j'
    return scalar n_theta=      `n_theta'
    return scalar n_d_ln_A=     `ds_d_ln_A'
    return scalar n_A_educ=     `n_d_ln_A'/4
    return scalar n_educ=       `n_educ'
    return scalar total_parameters= `n_sigma_j'+  `n_theta'+ `ds_d_ln_A'
end



