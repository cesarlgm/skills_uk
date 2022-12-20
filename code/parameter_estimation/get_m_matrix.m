function m_matrix=get_m_matrix(d_matrix,z_prime_z_inv,v_matrix)
    
    %Bread part of the 
    b_matrix=get_b_matrix(d_matrix,z_prime_z_inv);

    m_matrix=b_matrix*d_matrix*z_prime_z_inv*v_matrix*z_prime_z_inv*b_matrix;

end