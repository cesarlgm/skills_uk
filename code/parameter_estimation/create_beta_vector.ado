cap program drop create_beta_vector

program define create_beta_vector, rclass
    version 14.2
    syntax, sigma_vec(name)

    local n_col=rowsof(`sigma_vec')

    matrix define beta=J(`n_col',1,.)

    forvalues job=1/`n_col' {
        local sigma_j=`sigma_vec'[`job',1]
        
        if `sigma_j'==1 {
            local sigma_j=`sigma_j'+.0000001
        }
        
        matrix beta[`job',1]=`sigma_j'/(`sigma_j'-1)
    }

    return matrix beta=beta
end