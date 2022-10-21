


function e_squared=get_quadratic_form_ols_norest(parameter,z_matrix,y_var,s_matrix,size_vector,e1_dln_a_index,e1_educ_index)
    n_parameters=size(parameter,1);
    %First I compute the errors
    e_vector=create_moment_error_norest(parameter,y_var,s_matrix,size_vector,e1_dln_a_index,e1_educ_index);
    e_squared=transpose(transpose(z_matrix)*e_vector)*transpose(z_matrix)*e_vector;
    e_squared=e_squared/n_parameters;
end