function result=create_linear_vector(parameter_vector,size_vector, ...
        e1_job_index,e3_a_index,e3n_educ_index,e3d_educ_index)
    
    %Split parameter vector into parameter type
    splitted_vector=assign_parameters(parameter_vector,size_vector);

    %Extracting dlnA vector
    %First I create the full restricted dlna
    d_ln_a=splitted_vector{2};

    %Now I get the theta vector
    theta=splitted_vector{1};

    %Sigma vector
    sigmas=splitted_vector{3};

    %Pairwise education dummies
    comparison=splitted_vector{4};

    %Compute sigma/(sigma -1 )
    beta_inv=sigmas./(sigmas-1);

    %I assign the betas to the full error vector
    full_beta=assign_sigmas(beta_inv,e1_job_index);

    %I reorder the parameters in the "right order"
    %Parameters equation 1
    eqn1part_1=d_ln_a.*full_beta;
    
    
     %Now I start with assigning dlna job lines
     full_e3_a_vector=assign_thetas(d_ln_a,e3_a_index);
    
     %Now I assign thetas to the e3 parameter vectors
     full_e3n_theta=assign_thetas(theta,e3n_educ_index);
     full_e3d_theta=assign_thetas(theta,e3d_educ_index);


    %Parameters equation 3
    e3_num=full_e3_a_vector.*full_e3n_theta;
    e3_den=full_e3_a_vector.*full_e3d_theta;

    result=vertcat(eqn1part_1,theta,e3_num,e3_den,comparison);
end