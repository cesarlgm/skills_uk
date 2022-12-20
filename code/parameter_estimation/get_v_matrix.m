function V=get_v_matrix(parameter_vector,z_matrix,y_var,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index)
    
    n_obs=size(z_matrix,1);


    errors=create_moment_error(parameter_vector,y_var,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);

    
    b_i=transpose(z_matrix)*errors;

    V=(1/n_obs)*b_i*transpose(b_i);
end
