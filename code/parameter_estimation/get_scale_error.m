function scale_error=get_scale_error( parameter_vector, theta, ...
    data,computation_information,job_type_index)

    %Step 1: split the vector into scales and weights
    [scale_vector,scale_weights]=split_parameters(...
        parameter_vector,computation_information);

    %Step 2: I take the scale observations and compute skill indexes
    skill_indexes=create_skill_index(scale_vector, ...
        scale_weights,data,computation_information);

    %Step 3: I use the estimated theta to compute the theta error
    scale_error=theta_error(skill_indexes,theta,job_type_index);
end