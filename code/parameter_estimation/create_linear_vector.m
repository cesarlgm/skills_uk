function result=create_linear_vector(parameter_vector,size_vector, ...
        e1_job_index, e1_educ_index,e1_d_ln_a_index,e3_a_index,...
        e3n_index,e3d_index)
    
    %Split parameter vector into parameter type
    splitted_vector=assign_parameters(parameter_vector,size_vector);

    %Extracting dlnA vector
    %First I create the full restricted dlna
    d_ln_a=create_a_vector(splitted_vector{2});
  
    %Creates the skill by job full dlnA vector 
    e_1_full_d_ln_a=assign_thetas(d_ln_a,e1_d_ln_a_index);

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
    full_theta=assign_thetas(theta,e1_educ_index);
    
    %Now I start with assigning dlna job lines
    full_e3_a_vector=assign_thetas(d_ln_a,e3_a_index);

    %Now I assign thetas to the e3 parameter vectors
    full_e3n_theta=assign_thetas(theta,e3n_index);
    full_e3d_theta=assign_thetas(theta,e3d_index);


    %Parameters equation 1
    eqn1part_1=e_1_full_d_ln_a.*full_beta.*full_theta;
    eqn1part_2=d_ln_a;

    %Parameters equation 2 
    %theta

    %Parameters equation 3
    e3_num=full_e3_a_vector.*full_e3n_theta;
    e3_den=full_e3_a_vector.*full_e3d_theta;
    % + comparison

    theta    
    e3_num
    e3_den
    comparison
    
    result=vertcat(eqn1part_1,eqn1part_2,theta,e3_num,e3_den,comparison);
end