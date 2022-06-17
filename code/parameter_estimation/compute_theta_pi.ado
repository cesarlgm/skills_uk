cap program drop compute_theta_pi

program define compute_theta_pi, rclass
    syntax, lambda_mat(name) theta_mat(name) n_educ(integer) names(string)

    mata:    lambda_matrix=st_matrix("`lambda_mat'")


    forvalues e=1/`n_educ' { 
        mata:    theta_mat=st_matrix("`theta_mat'`e'")
        mata:    splitted_lambda=lambda_matrix:*theta_mat
        mata:    st_matrix("lambda`e'",splitted_lambda)

        if `e'==1 {
            matrix define full_lambda=lambda1
        }
        else {
            matrix define full_lambda=full_lambda \ lambda`e'
        }
        
    }
    matrix rownames full_lambda= `names'
    return matrix full_lambda=full_lambda
end

