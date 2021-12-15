function [theta,theta_matrix,skill_indexes]=extract_weights(scale_vector,scale_weights, ...
    data,observation_trackers,computation_information, n_educ)
    %Step 1> I take the solution scales and weights and compute the skill
    %indexes

   skill_indexes=create_skill_index(scale_vector, ...
        scale_weights,data,computation_information);

    %Step 2> I take the indexes and compute the final theta
    theta=theta_wrapper(skill_indexes,data,observation_trackers);

    %Step 3> create matrix for the output
    n_weights=length(theta);
    theta_matrix=reshape(theta,n_weights/n_educ,n_educ);
    theta_matrix=transpose(theta_matrix);

    row_names={'Low','Mid','High'};
    col_names={'Manual','Routine','Abstract','Social'};
    
    theta_matrix=array2table(theta_matrix,'VariableNames', col_names,'RowNames',row_names);
    
end