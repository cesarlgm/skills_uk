
function error=error_wrapper(parameter_vector, ...
    normalize_index,scale_dummies,scale_mult_matrix,index_composition, ...
    n_skills,occ_index,job_type_index,empshares)

    %Step 1: split the vector into scales and weights
    [scale_vector,scale_weights]=split_parameters(...
        parameter_vector,n_skills,normalize_index);

    %Step 2: I take the scale observations and compute skill indexes
    skill_indexes=create_skill_index(scale_vector, ...
        scale_weights,normalize_index,scale_dummies, ...
        scale_mult_matrix, index_composition);

    %Step 3: with those scales, compute the thetas
    theta=theta_wrapper(empshares,skill_indexes,occ_index,job_type_index);

    %Step 4: given those thetas I compute the MSE
    error=theta_error(skill_indexes,theta,job_type_index);
end