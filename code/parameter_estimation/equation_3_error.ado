cap program drop equation_3_error

program define equation_3_error, rclass

    syntax [if], at(name)

    if "`if'"=="" { 
        local if
    }
    else {
        local if &`if'
    } 
    
     *First I count parameters and divite the parameter vector into its components and extract the results
    {
        divide_parameters, parameters(`at')

        foreach number in n_skills n_sigma n_theta n_lambda n_educ {
            local `number'=`r(`number')'
        }

        matrix define sigma=r(sigma)
        matrix define theta=r(theta)
        matrix define raw_lambda=r(raw_lambda)
        matrix comparison_vector=r(comparison_vector)

        *I compute lambda
        expand_lambda, lambda_vec(raw_lambda) n_skills(`n_skills')
        matrix lambda=r(expanded_lambda)


        *We are cool here
        *Need to fix this part 
        *Divide theta's by education level
        split_theta, theta(theta) n_educ(`n_educ') l_A(`n_lambda')

        forvalues e=1/`n_educ' {
            matrix define theta`e'=r(theta`e')
        }

    

        compute_theta_pi, lambda_mat(lambda) theta_mat(theta) n_educ(`n_educ') names($ee_names)
        
        matrix define theta_pi=r(full_lambda)
        matrix rownames theta_pi=$ee_names
        matrix theta_pi=theta_pi'

        cap drop part1
        *This computes the \theta*S*dlnA
        matrix score part1=theta_pi

        *This computes the \theta*S_d*dlnA_d
        matrix  colnames theta_pi=$ee_names_d

        cap drop part2
        matrix score part2=theta_pi

        cap drop part3
        matrix comparison_vector=comparison_vector'
        matrix colnames comparison_vector=$x_names

        matrix score part3=comparison_vector
        
        local error_spc y_var-(part1-part2+part3) 
        cap generate gmm_error=`error_spc' if equation==3
        cap replace generate gmm_error=`error_spc' if equation==3
        cap drop part*
    }
end