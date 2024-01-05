% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_quadratic_form
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates the quadratic form in GMM e’Z’Ze.
% Functions it requires:
% -	create_moment_error

function e_squared=get_quadratic_form(parameter,y_var,ones_matrix,e2s_matrix,size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index)

    e_vector=create_moment_error(parameter,y_var,ones_matrix,e2s_matrix,size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index);

    e_squared=transpose(e_vector)*e_vector;

    e_squared=e_squared/size(e_vector,1);
end