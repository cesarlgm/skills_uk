function [ ... %alpha_D, alpha_restr,
           dummy_matrix, scale_restr,scale_matrix,sc_restr_matrix,n_scale,restriction_b]=create_problem_matrices(input_data,n_alpha) %skill_indexes,n_alpha)
   
    %I create restrictions for alpha matrices
    [alpha_D,alpha_restr,alpha_A]=alpha_restrictions(skill_indexes);

    %I create matrix of dummy variables for all the scales
    [dummy_matrix,scale_restr]=expand_matrix(input_data);

    %Let beta be the overall vector of parameteres. This functioncre
    [scale_matrix,sc_restr_matrix,restriction_b]=scaling_matrix(dummy_matrix,input_data,n_alpha); %,alpha_A add this if weights constrained to sum to one
 
    n_scale=sum(scale_restr==0);
end