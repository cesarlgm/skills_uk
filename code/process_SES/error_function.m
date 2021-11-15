function error=error_function(parameter,scale_dummies,restr_index,index_composition)
    %This function computes the error matrix in three steps>
    n_skills=sum(index_composition);
    
    %STEP 1> separate parameter vector into the appropriate components.
    [scale_vector,scale_weights,index_weights]=split_parameters(n_skills,normalize_index);
    

    %STEP 2> I create the matrix of skill indexes
    %this matrix combines information of all education groups
    skill_index_matrix=create_skill_index(scale_vector,scale_weights,normalize_vector);

    %STEP 3> I compute the sum of square errors.
    %MSE=compute_MSE(skill_index_matrix,skill_weights,education_index);
end