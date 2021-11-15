function skill_sums=compute_skill_sums(skill_index_matrix, education_index, ...
     index_weights)
   
    n_skill_indexes=size(skill_index_matrix,2);

    %STEP 1: restructure the skill index matrix into a block diagonal
    %matrix by education level
    reshaped_skill_index=educ_restructure(skill_index_matrix,education_index);


    %STEP 2: get index weight parameters (with normalizations)
    full_weights=restricted_weight(index_weights,n_skill_indexes);
  

    skill_sums=reshaped_skill_index*full_weights;
end