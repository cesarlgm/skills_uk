function [solution_array,scale_array,alpha_array,theta_array,theta_matrix_array,skill_index_array,MSE_array]= ... 
    solve_skill_problem(data,empshares,index_composition,n_initial_cond)

    %STRUCTURE OF THE PARAMETER VECTOR
    % Scales - scale weights

    
    %STEP 1: extract data required for calibration of scales
    [skill_data,job_type_index,occ_index,n_skills,index_names]=extract_scale_data(data);

    %Compute number of scales in the data
    n_scale_vector=count_n_scales(skill_data);
   
    %STEP 2: create matrix of dummies for the scales
        % - In this step I also create an index indicating with scales are 
        %   normalized to zero (-1) and to (1).
    [scale_dummies,normalize_index]=create_scale_dummies(skill_data);
    
    %STEP 3: create the matrices of non-negativity restrictions 
    [scale_mult_matrix,scale_restriction_mat]=create_scaling_matrix(scale_dummies,skill_data);
    
    fun=@(p)error_wrapper(p, ...
        normalize_index,scale_dummies,scale_mult_matrix,index_composition, ...
        n_skills,occ_index,job_type_index,empshares);

    [solution_array,MSE_array,n_educ]= ...
        create_solution_array(fun, n_initial_cond, ...
        normalize_index,scale_restriction_mat,job_type_index,...
        index_composition, n_scale_vector);


    [scale_array,alpha_array,theta_array,theta_matrix_array,skill_index_array]=extract_solution(solution_array,normalize_index, ...
        n_skills, n_educ,index_names,skill_data,scale_dummies,scale_mult_matrix, ...
        index_composition, empshares, occ_index, job_type_index);
end