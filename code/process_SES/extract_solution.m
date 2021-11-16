function [scale_vector,scale_weight_matrix,index_weight_matrix,index_matrix]= ...
    extract_solution(solution,normalize_vector, ...
            n_skills, n_educ,varnames,scale_dummies,scale_mult_matrix, ... 
            index_composition)
     
    [scale_vector,scale_weights,index_weights]=split_parameters(solution, ... 
         n_skills,normalize_vector);


    scale_weight_matrix=extract_alpha(scale_weights,varnames);


    index_weight_matrix=extract_weights(index_weights,n_educ);

    weight_vector=transpose(table2array(scale_weight_matrix));
    index_matrix=create_skill_index(scale_vector,weight_vector, ...
        normalize_vector,scale_dummies,scale_mult_matrix,index_composition);
end