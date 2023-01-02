function var_matrix=create_gmm_var(data,parameter,size_vector, ...
         e1_educ_index,e1_dln_a_index,e3_a_index,e3_occ_index,e3n_educ_index,... 
         e3d_educ_index,z_matrix,y_var,s_matrix)
    
    %I first computethe matrix of derivatives
    d_matrix=d_matrix_wrapper(data,parameter,size_vector, ...
         e1_educ_index,e1_dln_a_index,e3_a_index,e3_occ_index,e3n_educ_index,e3d_educ_index,z_matrix);


    %Compute z_prime_z_inv
    z_prime_z_inv=get_z_prime_z_inv(z_matrix);

    %Compute the bread matrix
    b_matrix=get_b_matrix(d_matrix,z_prime_z_inv);

    %Compute the variance of the errors
    v_matrix=get_v_matrix(parameter,z_matrix,y_var,s_matrix,...
        size_vector,e1_dln_a_index,e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);

    %Compute the meat
    m_matrix=get_m_matrix(d_matrix,z_prime_z_inv,v_matrix);

    %Compute estimate of the variance
    var_matrix=b_matrix*m_matrix*b_matrix;
end