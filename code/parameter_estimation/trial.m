
%%
var_matrix=create_gmm_var(data,parameter,size_vector, ...
         e1_educ_index,e1_dln_a_index,e3_a_index,e3_occ_index,e3n_educ_index,... 
         e3d_educ_index,z_matrix,y_matrix,s_matrix);


%% 


%%
[sd_matrix,z_indexes,i_indexes,sd2_matrix,num3s,den3s,comparison,num_z,den_z,e3job_index]=extract_sd_matrix(data);


%%
de_eq1=get_de_eq1(sd_matrix,theta, ...
    e1_educ_index,e1_dln_a_index,i_indexes,size_vector,e1_full_pi);


%%
d_matrix=create_d_matrix(z_matrix,z_indexes,i_indexes,n_total_parameters,de_eq1);

%%
de_eq3=get_de_eq3(parameter,num3s,den3s,comparison,e3_a_index,e3_occ_index,e3n_educ_index,e3d_educ_index,size_vector,e3job_index);
%%
d_matrix=create_d_matrix(z_matrix,z_indexes,i_indexes);

%% 

parameter=transpose(1:44);

splitted_vector=assign_parameters(parameter,size_vector);

%Assign theta and pi vector
theta=splitted_vector{1};
pi_vector=splitted_vector{2};

%Get the full vector of pi parameters


%%
index_matrix=get_sd_second_part(sd_matrix,theta,e1_educ_index,e1_dln_a_index,i_indexes,size_vector,e1_full_pi);

%%

sd2_matrix=get_de_eq2(sd2_matrix,size_vector);


%%
full_pi=get_d_matrix(parameter,z_matrix,sd_matrix,size_vector,e1_dln_a_index);

%%

sd_first_part=reshape_pi_vector(full_pi,e1_educ_index,sd_matrix,z_matrix);

%%



a=get_sd_second_part(sd_matrix,theta,e1_educ_index,e1_d_ln_a_index)