function V=estimate_v(parameter_vector,z_matrix,y_var,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index)
    
    n_obs=size(z_matrix,1);

    %First I compute the vector of errors from the model. This vector is of size Nx1
    errors=create_moment_error(parameter_vector,y_var,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index);

    %Next I compute the PxN matrix with columns given by phi(w_i)
    b=transpose(z_matrix)*diag(errors);

    %Finally I compute the estimate of the V matrix.
    V=(1/n_obs)*b*transpose(b);
end
