function MSE=error_function(parameter,scale_dummies,normalize_index,index_composition,scale_mult_matrix,education_index)
    %This function computes the error matrix in three steps>
    n_skills=sum(index_composition);
    n_educ=length(unique(education_index));
    
    %STEP 1> separate parameter vector into the appropriate components.
    [scale_vector,scale_weights,index_weights,sum_vector]= ...
         split_parameters(parameter,n_skills,normalize_index,n_educ);

    %STEP 2> I create the matrix of skill indexes
    %this matrix combines information of all education groups
    skill_index_matrix=create_skill_index(scale_vector,scale_weights, ...
        normalize_index,scale_dummies,scale_mult_matrix,index_composition);

    %STEP 3> I create the skill sums
    skill_sums=compute_skill_sums(skill_index_matrix,education_index,index_weights);

    %STEP 4> I create the vector of assumed total skill sums
    skill_sum_vector=create_sum_vector(education_index,sum_vector);

    %STEP 5> I compute the sum of square errors.
    MSE=compute_MSE(skill_sums,skill_sum_vector);
end