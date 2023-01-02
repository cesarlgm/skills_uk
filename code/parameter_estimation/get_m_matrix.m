function m_matrix=get_m_matrix(d_matrix,z_prime_z_inv,v_matrix)

    m_matrix=transpose(d_matrix)*z_prime_z_inv*v_matrix*z_prime_z_inv*d_matrix;

end