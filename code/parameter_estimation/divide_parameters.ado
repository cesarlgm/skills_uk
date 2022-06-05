cap program drop divide_parameters

program define divide_parameters, rclass
    syntax, parameters(name)

    qui count_parameters
    
    local n_skills=`r(n_skills)'
    local n_sigma=`r(n_sigma_j)'
    local n_theta=`r(n_theta)'
    local n_lambda=`r(n_d_ln_A)'
    local n_educ=`r(n_educ)'
    local n_ln_A=`r(n_A_educ)'

    local theta_vector

    *First I split the vector of parameters into their defining parts
    matrix define sigma=`parameters'[1..`n_sigma',1]
    matrix define theta=`parameters'[`n_sigma'+1..`n_theta'+`n_sigma',1]
    matrix define raw_lambda=`parameters'[`n_theta'+`n_sigma'+1..`n_lambda'+`n_theta'+`n_sigma',1]

    foreach number in n_sigma n_theta n_lambda n_educ n_ln_A {
        return scalar `number'=``number''        
    }

    return matrix sigma=sigma
    return matrix theta=theta
    return matrix raw_lambda=raw_lambda
end
