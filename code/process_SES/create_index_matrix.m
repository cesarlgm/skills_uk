function [i_matrix,n_indexes]=create_index_matrix(data,skill_indexes,scale_solution,education_vector)
    data_r=table2array(data);
    data_r(:,1:3)=[];

    n_skills=size(data_r,2);

    %compute the nymber of weights for skill variables
    n_alphas=n_skills-length(skill_indexes);

    %Compute all the matrices required to compute the index matrices
    [alpha_D, alpha_restr,dummy_matrix, scale_restr,scale_matrix,~,n_scale,~]=create_problem_matrices(data_r,skill_indexes,n_alphas);

    %Recovering the matrix of indexes
    r_matrix=rescaled_matrix(dummy_matrix,alpha_D,alpha_restr,scale_solution,n_scale,scale_restr,scale_matrix,skill_indexes);
    
    n_indexes=size(r_matrix,2);

    i_matrix=educ_restructure(r_matrix,education_vector);
end