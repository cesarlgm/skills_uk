function [z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector, ...
    e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index, lower_bound, ...
    upper_bound]=extract_data_matrices(data)
    %Defining number of parameters I need to compute:
    n_ln_A_effective=max(table2array(data(:,"ln_alpha")));
    n_ln_A_raw=n_ln_A_effective*4/3;
    n_sigma=max(table2array(data(:,"occ_id")));
    n_theta=12;
    n_comparison=max(table2array(data(:,"ee_group_id")));
    n_total_parameters=n_sigma+n_theta+n_ln_A_effective+n_comparison;

    %size vector gives the info necessary to split the parameter vector
    %into parts
    size_vector=[n_theta;n_ln_A_effective;n_sigma;n_comparison];

    lower_bound=vertcat(zeros(n_theta,1),-Inf*ones(n_total_parameters-n_theta,1));
    upper_bound=vertcat(ones(n_theta,1),Inf*ones(n_total_parameters-n_theta,1));

    %I get the data matrices
    y_matrix=get_y_var(data);
    z_matrix=get_z_matrix(data);
    
    %s is the matrix I use for multiplying with the parameters
    s_matrix=get_s_matrix(data);

    %These are the eoccupation indexes form equations 1 and 3s
    [e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index]=get_occ_indexes(data);
end