%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: César Garro-Marín
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function computes variance matrix \bar{V}

function variance_matrix=get_variance_matrix(parameter_vector, size_vector, y_var,e1_dln_a_index,e1_occ_index,e1_theta_code,e1_theta_code_den,gradient_matrix,aweight)
    
    n_obs=size(y_var,1);
   
    %Fixed with number of observations weighting
    hessian=get_hessian(parameter_vector, size_vector, y_var,e1_dln_a_index,e1_occ_index,e1_theta_code,e1_theta_code_den,aweight);

    v_matrix=estimate_v(parameter_vector,gradient_matrix,size_vector,y_var,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index,aweight);
    
    inv_hessian=eye(size(hessian))/hessian;
    
    variance_matrix=inv_hessian*v_matrix*inv_hessian;
end