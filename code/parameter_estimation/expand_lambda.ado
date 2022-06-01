cap program drop expand_lambda


program define expand_lambda, rclass
    version 14.2
    syntax, lambda_vec(name) n_skills(integer)

    local final_lambda_size=rowsof(`lambda_vec')/(`n_skills'-1)*`n_skills'

    matrix define expanded_lambda=J(`final_lambda_size',1,0)

    local counter=1
    forvalues row=1/`final_lambda_size' {
        if mod(`row',`n_skills')!=0 {
            matrix expanded_lambda[`row',1]=`lambda_vec'[`counter',1]
            local ++counter
        }
    }

    return matrix expanded_lambda=expanded_lambda
end