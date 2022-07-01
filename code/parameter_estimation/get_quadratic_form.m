function e_squared=get_quadratic_form(parameter,z_matrix,y_var,s_matrix,size_vector,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index)
    
    %First I compute the errors
    e_vector=create_moment_error(parameter,y_var,s_matrix,size_vector,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);
    e_squared=transpose(transpose(z_matrix)*e_vector)*transpose(z_matrix)*e_vector;
    e_squared=e_squared/size(e_vector,1);
end