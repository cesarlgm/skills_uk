function skill_index_matrix= create_skill_index(scale_vector, ...
        scale_weights,data,computation_information)

    %Extracting data from the inputs
    scale_dummies=data{1};
    scale_mult_matrix=data{2};
    normalize_vector=computation_information{3};
    index_composition=computation_information{2};
 
    %This function takes the vector of scales and scale weights to spit out
    %the skill index matrices

    normalized_scales=assign_scales(scale_vector,normalize_vector);

    skill_use_matrix=scale_dummies*diag(normalized_scales)*scale_mult_matrix;

    %Now I create the matrix of skill indexes
    skill_index_matrix=create_index_matrix(skill_use_matrix, ...
        scale_weights, index_composition);
end