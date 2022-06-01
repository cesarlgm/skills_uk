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
    
    *First I count parameters
    qui count_parameters

    local n_skills=`r(n_skills)'
    local n_sigma=`r(n_sigma_j)'
    local n_theta=`r(n_theta)'
    local n_lambda=`r(n_d_ln_A)'
    local n_educ=`r(n_educ)'
    local n_ln_A=`r(n_A_educ)'

    local theta_vector

    *First I split the vector of parameters into their defining parts
    matrix define sigma=`at'[1..`n_sigma',1]
    matrix define theta=`at'[`n_sigma'+1..`n_theta'+`n_sigma',1]
    matrix define raw_lambda=`at'[`n_theta'+`n_sigma'+1..`n_lambda'+`n_theta'+`n_sigma',1]

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
        cap drop equation_error
        generate equation_error=y_var-`error_1'+`error_2'  if equation==1`if'
    }

end

