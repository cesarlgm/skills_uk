% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_quadratic_form
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates the quadratic form in GMM e’Z’Ze.
% Functions it requires:
% -	create_moment_error

function e_squared=get_quadratic_form(parameter,z_matrix,y_var,s_matrix,size_vector,e1_dln_a_index,e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index)
    n_parameters=size(z_matrix,2);
    %First I compute the errors
    e_vector=create_moment_error(parameter,y_var,s_matrix,size_vector,e1_dln_a_index,e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);
    z_prime_z_inv=eye(n_parameters)/(transpose(z_matrix)*z_matrix);
    e_squared=transpose(transpose(z_matrix)*e_vector)*z_prime_z_inv*transpose(z_matrix)*e_vector;
    e_squared=e_squared/size(e_vector,1);
end