%I drop the n's because there is a scaling problem
function v_matrix=estimate_v(parameter,gradient_matrix,size_vector,y_var,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index)
    
    n_obs=size(gradient_matrix,1);

    error=create_moment_error(parameter,y_var,...
        size_vector,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index);


    size_vector_adj=size_vector;
    size_vector_adj(1,1)=size_vector_adj(1,1)-3;
   
  
    cell_size=size(gradient_matrix,1);
    splitted_matrix=mat2cell(gradient_matrix,cell_size,size_vector_adj);

    theta_matrix=splitted_matrix{1};
    d_matrix=splitted_matrix{2};
    b_matrix=splitted_matrix{3};

    splitted_vector=assign_parameters(parameter,size_vector);

    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};
    b_j=splitted_vector{3};

    full_theta_vector=assign_thetas(theta,e1_theta_code);
    full_dlna_vector=assign_thetas(d_ln_a,e1_dln_a_index);
    full_b_j_vector=assign_thetas(b_j,e1_occ_index);

    partial_theta=full_b_j_vector./full_theta_vector;
    partial_b_j=log(full_theta_vector);

    partial_theta_matrix=repmat(partial_theta,1,size(theta_matrix,2));
    partial_b_j_matrix=repmat(partial_b_j,1,size(b_matrix,2));
    


    derivatives=horzcat(theta_matrix.*partial_theta_matrix,d_matrix,b_matrix.*partial_b_j_matrix);

    error_matrix=repmat(error,1,size(derivatives,2));
    
    gradient_matrix=error_matrix.*derivatives;

    v_matrix=transpose(gradient_matrix(1,:))*gradient_matrix(1,:);
    for i=2:n_obs
        new=transpose(gradient_matrix(i,:))*gradient_matrix(i,:);
        v_matrix=v_matrix+new;
    end
end