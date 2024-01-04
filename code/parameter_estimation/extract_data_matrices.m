function [z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector, ...
    e1_dlna_index,e1_educ_index,e1_code,e1_occ_index,lower_bound, ... 
    upper_bound]=extract_data_matrices(data,n_skills)

    %Defining number of parameters I need to compute:
    n_ln_A_effective=max(table2array(data(:,"ln_alpha")));
    n_theta=3*n_skills;
    n_sigma=max(table2array(data(:,"occ_id")));
    n_total_parameters=n_theta+n_ln_A_effective+n_sigma;

    %size vector gives the info necessary to split the parameter vector
    %into parts
    size_vector=[n_theta;n_ln_A_effective;n_sigma];

    lower_bound=vertcat(zeros(n_theta,1),-Inf*ones(n_ln_A_effective,1),-Inf*ones(n_sigma,1),-Inf*ones(n_comparison,1));
    upper_bound=vertcat(Inf*ones(n_theta,1),Inf*ones(n_ln_A_effective,1),Inf*ones(n_sigma,1),Inf*ones(n_comparison,1));

    %I get the data matrices
    y_matrix=get_y_var(data);
    z_matrix=get_z_matrix(data);
    
    %s is the matrix I use for multiplying with the parameters
    s_matrix=get_s_matrix(data);

    %These are the eoccupation indexes form equations 1 and 3s
    [e1_code,e1_dlna_index,e1_educ_index,e1_occ_index]=get_occ_indexes(data, n_skills);
end