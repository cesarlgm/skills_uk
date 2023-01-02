function d_matrix=d_matrix_wrapper(data,parameter_vector,size_vector, ...
         e1_educ_index,e1_dln_a_index,e3_a_index,e3_occ_index,e3n_educ_index,e3d_educ_index,z_matrix)
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Extracting the parameters
    splitted_vector=assign_parameters(parameter_vector,size_vector);

    theta=splitted_vector{1};
    pi_vector=splitted_vector{2};

    n_parameters=sum(size_vector);

    
    e1_full_pi=assign_thetas(pi_vector,e1_dln_a_index);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %First I get the matrices I need for the derivatives matrix
    [sd_matrix,z_indexes,i_indexes,sd2_matrix,num3s, ...
        den3s,comparison,num_z,den_z,e3job_index]=extract_sd_matrix(data);

    n_obs=size(sd_matrix,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %FIRST PART OF THE DERIVATIVE MATRIX
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %First I compute the derivatives of the first error equation
    de_eq1=get_de_eq1(sd_matrix,theta, ...
        e1_educ_index,e1_dln_a_index,i_indexes,n_parameters,e1_full_pi);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SECOND PART OF THE DERIVATIVE MATRIX
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Compute the derivatives of the second error equation
    de_eq2=get_de_eq2(sd2_matrix,n_parameters);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %THIRD PART OF THE DERIVATIVE MATRIX
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Compute the derivatives of the last error equation
    de_eq3=get_de_eq3(parameter_vector,num3s,den3s,comparison,e3_a_index,e3_occ_index,e3n_educ_index,e3d_educ_index,size_vector,e3job_index);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PUTTING EVERYTHING TOGETHER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %I put everything together
    d_matrix=-(1/n_obs)*create_d_matrix(z_matrix,z_indexes,i_indexes,n_parameters,de_eq1,de_eq2,de_eq3);

end