function [scale_matrix,alpha_vec,s_weights]=solve_skill_problem(parameters,data,educ_reference,skill_indexes)
    %STRUCTURE OF THE PARAMETER VECTOR
    % Scales - scale weights - index weights 
    

    %STEP 1: extract data required for calibration of scales
    [skill_data,education_index,n_skills]=extract_scale_data(data);

    %STEP 2: create matrix of dummies for the scales
        % - In this step I also create an index indicating with scales are 
        %   normalized to zero (-1) and to (1).
    [skill_dummies,normalize_index]=create_scale_dummies(skill_data);
    
    %STEP 3: create the matrices of non-negativity restrictions 
    [scale_mult_matrix,scale_restriction_mat]=create_scaling_matrix(skill_dummies,skill_data);

    %STEP 4: start solving the problem
    %in the to do> handle the initial condition



    %STEP 3: separate the parameter vector into their functional components

    
end