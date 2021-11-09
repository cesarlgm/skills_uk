function [alpha_D, alpha_restr,dummy_matrix, scale_restr,scale_matrix,sc_restr_matrix,n_scale,restriction_b]=create_problem_matrices(input_data,skill_indexes,n_alpha)
    
    %Uncomment this section to eliminate the restrictions on alpha
    %I create restrictions for alpha matrices
    %[alpha_D,alpha_restr,alpha_A]=alpha_restrictions(skill_indexes);

    %I create matrix of dummy variables for all the scales
    [dummy_matrix,scale_restr]=expand_matrix(input_data);

    %Let beta be the overall vector of parameteres. This functioncre
    [scale_matrix,sc_restr_matrix,restriction_b]=scaling_matrix(dummy_matrix,input_data,alpha_A);
 
    n_scale=sum(scale_restr==0);
end