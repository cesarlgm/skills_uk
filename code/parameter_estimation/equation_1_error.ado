cap program drop equation_1_error

program define equation_1_error, rclass
    version 14.2
    
    syntax [if], at(name) job_index(name) 
    if "`if'"=="" { 
        local if
    }
    else {
        local if &`if'
    } 
    
    *First I count parameters and divite the parameter vector into its components and extract the results
    {
        qui divide_parameters, parameters(`at')

        foreach number in n_skills n_sigma n_theta n_lambda n_educ n_ln_A {
            local `number'=`r(`number')'
        }

        matrix define sigma=r(sigma)
        matrix define theta=r(theta)
        matrix define raw_lambda=r(raw_lambda)
    }

    *Next I expand the lambda vector by imposing the 0 restriction
    {
        expand_lambda, lambda_vec(raw_lambda) n_skills(`n_skills')

        matrix lambda=r(expanded_lambda)

    }


    *Next I create the beta vector:
    {
        assign_sigmas, sigma_vec(sigma) job_index(`job_index')
        matrix define beta=r(assigned_sigma)
    }

    *Next I compute the product of beta*lambda
    {
        mata: pi_vector=st_matrix("beta"):*st_matrix("lambda")
        mata: st_matrix("pi_vector", pi_vector)

        *I append all the pi's
        matrix define full_pi=pi_vector
        forvalues e=2/`n_educ' {
            matrix  define full_pi=full_pi \ pi_vector
        }
        
        matrix rownames full_pi=$names_dummy
        matrix define full_pi=full_pi'

    }

    *Finally, I compute the product of theta*pi
    {
        *Sub step 1: split thetas
        split_theta, theta(theta) n_educ(`n_educ') l_A(`n_ln_A')
        forvalues e=1/`n_educ' {
            matrix define theta`e'=r(theta`e')
        }

        *Sub step 2: create product of theta * pi
        compute_theta_pi, lambda_mat(pi_vector) theta_mat(theta) n_educ(`n_educ')

        matrix define theta_pi=r(full_lambda)'
    }


    *Now I compute the first part of the error
    {

        tempvar error_1
        matrix score `error_1'=theta_pi if equation==1`if'

    }

    *Now I compute the second part of the error
    {
        tempvar error_2
        matrix score `error_2'=full_pi if equation==1`if'

    }

    *Finally I compute the full error
    {   
        cap drop gmm_error
        generate gmm_error=y_var-`error_1'+`error_2'  if equation==1`if'
    }

end

