capture program drop count_parameters

program define count_parameters, rclass 
    version 14.2

    qui unique(year_id)  if !missing(y_var)&equation==1
    local n_years=`r(unique)'

    qui unique(education) if  !missing(y_var)&equation==1
    local n_educ=`r(unique)'


    qui unique(occupation) if !missing(y_var)&equation==1
    local n_sigma_j=`r(unique)'

    local n_skills: word count $index_list
    qui unique education if !missing(y_var)&equation==1
    local n_educ `r(unique)'
    local n_theta=`n_educ'*`n_skills'

    tempvar d_ln_A
    qui egen `d_ln_A'=group(occupation year skill) if equation==1
    qui unique `d_ln_A'  if equation==1
    local total_d_ln_A_size=`r(unique)'
    local n_ln_A_compute= `total_d_ln_A_size'/4*3

    local n_comparisons=exp(lnfactorial(`n_educ'))/(2*exp(lnfactorial(`n_educ'-2)))*`n_years'

    return scalar n_skills=4
    return scalar n_sigma_j=        `n_sigma_j'
    return scalar n_theta=          `n_theta'
    return scalar total_d_ln_A_size=`total_d_ln_A_size'
    return scalar n_ln_A_compute=   `n_ln_A_compute'
    return scalar n_educ=           `n_educ'
    return scalar n_comparisons=    `n_comparisons'
    return scalar total_parameters= `n_sigma_j'+  `n_theta'+ `n_ln_A_compute'+`n_comparisons'
end



