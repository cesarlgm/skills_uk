function skill_index_matrix= create_skill_index(scale_vector, ...
        scale_weights,normalize_vector,scale_dummies, ...
        scale_mult_matrix, index_composition)
    %This function takes the vector of scales and scale weights to spit out
    %the skill index matrices

    normalized_scales=assign_scales(scale_vector,normalize_vector);

    skill_use_matrix=scale_dummies*diag(normalized_scales)*scale_mult_matrix;

    %Now I create the matrix of skill indexes
    skill_index_matrix=create_index_matrix(skill_use_matrix, ...
        scale_weights, index_composition);

    %
end