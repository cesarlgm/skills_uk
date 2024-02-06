function hessian=get_hessian(parameter_vector,size_vector,y_var,e1_dln_a_index,e1_occ_index,e1_theta_code,e1_theta_code_den)
    
    errors=create_moment_error(parameter_vector,y_var,size_vector,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index);

    n_total_parameters=sum(size_vector)-4;
    n_obs=size(y_var,1);

    hessian=zeros(n_total_parameters,n_total_parameters);
    for obs=1:n_obs
        hessian_obs=get_hessian_obs(parameter_vector,size_vector,e1_dln_a_index,e1_occ_index,e1_theta_code,obs,errors);
        hessian=hessian+hessian_obs;
    end

    hessian=hessian;
end