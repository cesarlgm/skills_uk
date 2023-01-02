function z_prime_z_inv=get_z_prime_z_inv(z_matrix)
    z_size=size(z_matrix,2);
    z_obs=size(z_matrix,1);
    z_prime_z_inv=eye(z_size)/((1/z_obs)*transpose(z_matrix)*z_matrix);
end