function z_prime_z_inv=get_z_prime_z_inv(z_matrix)
    z_size=size(z_matrix,1);
    z_prime_z_inv=eye(z_size)/(transpose(z_matrix)*z_matrix);
end