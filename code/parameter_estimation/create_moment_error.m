%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create_moment_error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates the error vector for the GMM equation. 
% Functions it requires:
% -	create_linear_vector
% -	assign_thetas


function errors=create_moment_error(parameter_vector,y_var,ones_matrix,e2s_matrix,...
    size_vector,e1_dln_a_index,e1_theta_code,e1_occ_index)
    %Step 0: assign parameters
    splitted_vector=assign_parameters(parameter_vector,size_vector);

    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};
    sigma=splitted_vector{3};


    full_theta_vector=assign_thetas(theta,e1_theta_code);
    full_dlna_vector=assign_thetas(d_ln_a,e1_dln_a_index);
    full_sigma_vector=assign_thetas(sigma,e1_occ_index);

    %Step 1: compute the numerator of the ratio.
    a_power=-full_sigma_vector./(full_sigma_vector-1);
    theta_power=ones(size(full_sigma_vector,1),1)./(full_sigma_vector-1);

    numerator=(full_dlna_vector.^a_power).*(full_theta_vector.^theta_power);


    %Step 2: compute the denominator
    theta_power_den=-a_power;

    tem_den=(full_dlna_vector.^a_power).*(full_theta_vector.^theta_power_den);
    denominator=ones_matrix*tem_den;
    
    e1_rhs=log(numerator)-log(denominator);

    %Step 2: Compute rhs for the second equation
    e2_rhs=e2s_matrix*theta;

    rhs=vertcat(e1_rhs,e2_rhs);

    errors=y_var-rhs;
end