% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_quadratic_form
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates the quadratic form in GMM e’Z’Ze.
% Functions it requires:
% -	create_moment_error

function e_squared=get_quadratic_form(parameter,y_var,size_vector,e1_dln_a_index,e1_theta_index,e1_theta_index_den,e1_occ_index,aweight_matrix,weighted)

    e_vector=create_moment_error(parameter,y_var,size_vector,e1_dln_a_index,e1_theta_index,e1_theta_index_den,e1_occ_index);

    if weighted==0
        e_squared=transpose(e_vector)*e_vector;
    elseif weighted==1
        e_squared=transpose(e_vector)*(aweight_matrix.*e_vector);
    end
    e_squared=e_squared/size(e_vector,1);
end