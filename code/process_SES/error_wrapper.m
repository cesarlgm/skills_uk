function error=error_wrapper(scale_vector,skill_indexes,occ_index,job_type_index)
    %Step 2: with those scales, compute the thetas
    theta=theta_wrapper(empshares,skill_indexes,occ_index,job_type_index);

    %Step 3: given those thetas I compute the errors 
    error=compute_
end