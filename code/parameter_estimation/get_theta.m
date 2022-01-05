function [theta,job_type]=get_theta(parameter_vector, ...
    data, observation_trackers,computation_information)

    %Step 1: split the vector into scales and weights
    [scale_vector,scale_weights]=split_parameters(...
        parameter_vector,computation_information);

    %Step 2: I take the scale observations and compute skill indexes
    skill_indexes=create_skill_index(scale_vector, ...
        scale_weights,data,computation_information);


    %Step 3: with those scales, compute the thetas
    [theta,job_type]=theta_wrapper(skill_indexes,data,observation_trackers);
end