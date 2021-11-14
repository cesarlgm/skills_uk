function [scale,index_l]=solve_scale_problem(data,education,skill_indexes)
    
    %extract data required for calibration of scales
    [input_data,n_skills]=extract_scale_data(data,education);

    %Uncomment these lines if alphas are restricted to sum to one.
        %With imposed restrictions
        %compute the number of weights for skill variables
        %n_alphas=n_skills-length(skill_indexes);
    
    n_alphas=n_skills;


    %Compute all the matrices required as inputs for the function
    [ ... %alpha_D, alpha_restr,
        dummy_matrix, scale_restr,scale_matrix,sc_restr_matrix,n_scale,restriction_b]=create_problem_matrices(input_data,n_alphas); %,skill_indexes,n_alphas);

    options = optimset('PlotFcns',@optimplotfval,'TolX',1e-10,'MaxFunEvals',10000e3);
    

    %Setting initial values
    scale0=1/n_scale*ones(n_scale,1);
    alpha0=1/n_alphas*ones(n_alphas,1);
    parameter0=vertcat(scale0,alpha0);
    
    %Anonymizing the function
    fun=@(p)scale_function(p, ... %alpha_D,alpha_restr,
        dummy_matrix,scale_matrix,scale_restr);
    
    %Solving the problem
    scale=fmincon(fun,parameter0,sc_restr_matrix,restriction_b,[],[],zeros(n_scale+n_alphas,1),ones(n_scale+n_alphas,1),[],options);

    %Recovering the matrix of indexes
    index_l=rescaled_matrix(dummy_matrix, ...
        ... %alpha_D,alpha_restr,
        scale,n_scale,scale_restr,scale_matrix,skill_indexes);
end