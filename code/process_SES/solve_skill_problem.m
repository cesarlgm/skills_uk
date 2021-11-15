function [scale_matrix,alpha_vec,s_weights]=solve_skill_problem(data,index_composition)
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

    %STEP 4: set up initial condition
    %in the to do> handle the initial condition
    n_scales=sum(normalize_index==0);
    n_educ=length(unique(education_index));
    n_indexes=length(index_composition);

    parameter0=create_initial_guess(n_scales,n_skills,n_educ,n_indexes);

    fun=@(p)error_function(p,skill_dummies,normalize_index,index_composition, ...
        scale_mult_matrix,education_index);

    n_parameters=size(parameter0,1);

    %STEP 5
    %fix size of mrestruction matrix
    missing_columns=n_parameters-size(scale_restriction_mat,2);
    restriction_size=size(scale_restriction_mat,1);
    parameter_restriction_matrix=horzcat(scale_restriction_mat, ...
           zeros(restriction_size,missing_columns));
    restriction_b=zeros(restriction_size,1);

    %STEP 5: solve the problem
    options = optimset('Display','iter','TolX',1e-10,'MaxFunEvals',10000e3);
    
    solution=fmincon(fun,parameter0,parameter_restriction_matrix,restriction_b,[],[],zeros(n_parameters,1), ...
       [],[],options)
    scale_matrix=solution;
end