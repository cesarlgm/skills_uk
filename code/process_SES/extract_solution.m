function [scale_array,scale_weight_array,index_weight_array,index_matrix_array]= ...
            extract_solution(solution_array,normalize_vector, ...
            n_skills, n_educ,varnames,skill_data,scale_dummies,scale_mult_matrix, ... 
            index_composition)
    
    n_solutions=length(solution_array);

    scale_array={};
    scale_weight_array={};
    index_weight_array={};
    index_matrix_array={};

    for i=1:n_solutions
        
        %First I extract all the elements of the solution
        [scale_vector,scale_weights,index_weights]=split_parameters(solution_array{i}, ... 
             n_skills,normalize_vector);
    
        scale_matrix=create_output_scale_matrix(scale_vector,skill_data,n_skills,varnames);
    
        scale_weight_matrix=extract_alpha(scale_weights,varnames);
    
    
        index_weight_matrix=extract_weights(index_weights,n_educ);
    
        weight_vector=transpose(table2array(scale_weight_matrix));
        index_matrix=create_skill_index(scale_vector,weight_vector, ...
            normalize_vector,scale_dummies,scale_mult_matrix,index_composition);

        %Now I write the elements into the output array
        scale_array{i}=scale_matrix;
        scale_weight_array{i}=scale_weight_matrix;
        index_weight_array{i}=index_weight_matrix;
        index_matrix_array{i}=index_matrix;
    end

    %Extract average of solutions
    mean_sol=mean(cell2mat(solution_array),2);

    %First I extract all the elements of the solution
    [scale_vector,scale_weights,index_weights]=split_parameters(mean_sol, ... 
         n_skills,normalize_vector);

    scale_matrix=create_output_scale_matrix(scale_vector,skill_data,n_skills,varnames);

    scale_weight_matrix=extract_alpha(scale_weights,varnames);


    index_weight_matrix=extract_weights(index_weights,n_educ);

    weight_vector=transpose(table2array(scale_weight_matrix));
    index_matrix=create_skill_index(scale_vector,weight_vector, ...
        normalize_vector,scale_dummies,scale_mult_matrix,index_composition);

    %Now I write the elements into the output array
    scale_array{n_solutions+1}=scale_matrix;
    scale_weight_array{n_solutions+1}=scale_weight_matrix;
    index_weight_array{n_solutions+1}=index_weight_matrix;
    index_matrix_array{n_solutions+1}=index_matrix;
end