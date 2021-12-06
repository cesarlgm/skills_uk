function [scale_matrix,alpha_vec,s_weights]=extract_solution_data(data,indexes,scale_solution,weight_sol, n_educ)
    data_r=data;
    data_r(:,1:3)=[];

    varnames=data_r.Properties.VariableNames

    n_skills=size(data_r,2);

    %Compute the number of scales vector
    n_scales=extract_n_scales(data_r,n_skills);

    scale_matrix=create_scale_matrix(scale_solution,n_scales,n_skills,varnames);

    alpha_vec=extract_alpha(scale_solution,n_scales,indexes,varnames);

    s_weights=extract_weights(weight_sol,n_educ);
end