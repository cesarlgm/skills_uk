function [theta,theta_matrix,skill_indexes]=extract_weights(scale_vector,scale_weights, ...
    normalize_index,scale_dummies,scale_mult_matrix,index_composition, ...
    empshares, occ_index, job_type_index, n_educ)
    %Step 1> I take the solution scales and weights and compute the skill
    %indexes

   skill_indexes=create_skill_index(scale_vector, ...
    scale_weights,normalize_index,scale_dummies, ...
    scale_mult_matrix, index_composition);

    %Step 2> I take the indexes and compute the final theta
    theta=theta_wrapper(empshares,skill_indexes,occ_index,job_type_index);

    %Step 3> create matrix for the output
    n_weights=length(theta);
    theta_matrix=reshape(theta,n_weights/n_educ,n_educ);
    theta_matrix=transpose(theta_matrix);

    row_names={'Low','Mid','High'};
    col_names={'Manual','Routine','Abstract','Social'};
    
    theta_matrix=array2table(theta_matrix,'VariableNames', col_names,'RowNames',row_names);
    
end