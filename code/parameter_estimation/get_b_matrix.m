function b_matrix=get_b_matrix(d_matrix,z_prime_z_inv)
    d_cols=size(d_matrix,2);

    b_matrix=eye(d_cols)/(transpose(d_matrix)*z_prime_z_inv*d_matrix);
end