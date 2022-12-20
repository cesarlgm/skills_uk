function b_matrix=get_b_matrix(d_matrix,z_prime_z_inv)
    d_rows=size(d_matrix,1);

    b_matrix=eye(d_rows)/(d_matrix*z_prime_z_inv*d_matrix);
end