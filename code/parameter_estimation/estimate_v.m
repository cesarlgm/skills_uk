%I drop the n's because there is a scaling problem
function v_matrix=estimate_v(parameter,gradient_matrix,size_vector,y_var,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index)
    
    %Computing number of observations
    n_obs=size(gradient_matrix,1);
    
    %I evaluate the error function at the solution
    error=create_moment_error(parameter,y_var,...
        size_vector,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index);

    %Note that I am not estimating 3 thetas, therefore I need to adjust the
    %parameter count
    size_vector_adj=size_vector;
    %I am normalizing 3 thetas and 1 b_j
    size_vector_adj(1,1)=size_vector_adj(1,1)-3;
    size_vector_adj(3,1)=size_vector_adj(3,1)-1;
   
    %Here I split the matrix of gradient variables into components by the
    %type of parameters.
    cell_size=size(gradient_matrix,1);
    splitted_matrix=mat2cell(gradient_matrix,cell_size,size_vector_adj);

    %This has the indicators for the derivatives with respect to theta
    theta_matrix=splitted_matrix{1};
    %This has the derivative indicators for the derivatives with respect to
    %D_ijt
    d_matrix=splitted_matrix{2};
    %This has the derivative indicators with respect to the b_js
    b_matrix=splitted_matrix{3};

    %here I split the solution vector into each of the components
    splitted_vector=assign_parameters(parameter,size_vector);

    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};
    b_j=splitted_vector{3};


    %And then assign the parameters relevant to each observation
    full_theta_vector=assign_thetas(theta,e1_theta_code);
    full_dlna_vector=assign_thetas(d_ln_a,e1_dln_a_index);
    full_b_j_vector=assign_thetas(b_j,e1_occ_index);

    %This computes the vector of b_j/\theta_ei
    partial_theta=full_b_j_vector./full_theta_vector;
    
    %This computes the vector of b_js
    partial_b_j=log(full_theta_vector);
    
    %Next I create the vector of derivatives
    %For this I first create a matrix to multiply the partial vector to
    %each column of the derivative indicators
    partial_theta_matrix=repmat(partial_theta,1,size(theta_matrix,2));
    partial_b_j_matrix=repmat(partial_b_j,1,size(b_matrix,2));
    
    %Because the matrices are just dummies, then the derivative vector will
    %have zeros everywhere but the appropriate entries
    %Then I create the vector of derivatives
    derivatives=horzcat(theta_matrix.*partial_theta_matrix,d_matrix,b_matrix.*partial_b_j_matrix);

    %So at this point I have only derivatives of the conditional
    %expectation.

    %Finally, I create the Nxk gradient matrix matrix. Each row has the 
    %gradient for each of the observations. 

    %To do this, I create a matrix with each column being the error of the
    %observation.
    error_matrix=repmat(error,1,size(derivatives,2));
    gradient_matrix=-2*error_matrix.*derivatives;

    f_gradient=1/n_obs*transpose(sum(gradient_matrix));

    %Finally I compute the variance matrix by summing across observations.
    %This yields a kxk matrix
    v_matrix=transpose(gradient_matrix(1,:))*gradient_matrix(1,:);
    for i=2:n_obs
        new=transpose(gradient_matrix(i,:))*gradient_matrix(i,:);
        v_matrix=v_matrix+new;
    end
end