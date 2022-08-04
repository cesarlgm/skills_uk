

%%
clear

%%

options = optimoptions('fmincon','Display','iter','MaxFunctionEvaluations',1000000);



cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');



data_path="data/additional_processing/gmm_example_dataset.csv";
sol_path="data/additional_processing/initial_estimates.csv";

%% 

data=readtable(data_path);
init_sol=readtable(sol_path);


%%
init_sol_vec=table2array(init_sol(:,'estimate'));

    
%%

[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector,e1_dln_a_index,e1_educ_index, e1_code, ...
    lower_bound, upper_bound]= extract_data_matrices(data);


%%
%I start by generating the dummy parameter vector
trial_param=transpose(1:1320);


%%

e_vector=create_moment_error(trial_param,y_matrix,s_matrix,size_vector,e1_dln_a_index,e1_educ_index);


