%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%THIS FUNCTION COMPUTES THE VARIANCE OF THE OF THE GMM ESTIMATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function variance=get_variance(parameter_vector,z_matrix,y_var,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index)
    
    %First I get the v_matrix
    v_matrix=get_v_matrix(parameter_vector,z_matrix,y_var,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);

    %first I get z_matrix
    z_prime_z_inv=get_z_prime_z_inv(z_matrix);

    %Next I get the gradient matrix
    d_matrix=get_d_matrix(parameter_vector);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SANDWICH BREAD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    b_matrix=get_b_matrix(d_matrix,z_prime_z_inv);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SANDWICH MEAT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m_matrix=get_m_matrix(d_matrix,z_prime_z_inv,v_matrix);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %I COMPUTE THE VARIANCE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    variance=b_matrix*m_matrix*b_matrix;
end