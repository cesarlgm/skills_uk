

%%
clear;

%%

options = optimoptions('fmincon','Display','iter','MaxIterations',3000,'MaxFunctionEvaluations',500000);



cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');
%% 



data_path="data/additional_processing/gmm_example_dataset_ols.csv";
sol_path="data/additional_processing/initial_estimates.csv";

%% 

data=readtable(data_path);
init_sol=readtable(sol_path);


%%
init_sol_vec=table2array(init_sol(:,'parameter'));

    
%%

[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector,e1_dln_a_index,e1_educ_index, e1_code, ...
    lower_bound, upper_bound]= extract_data_matrices_norest(data);


%%

error_solve=@(p)get_quadratic_form_ols_norest(p, z_matrix,y_matrix,s_matrix,size_vector,e1_dln_a_index,e1_educ_index);

%%
    
[solution,MSE]=fmincon(error_solve,init_sol_vec,[],[],[],[],lower_bound, upper_bound,[],options);

%%

[solution,MSE]=fmincon(error_solve,solution,[],[],[],[],lower_bound, ...
           [],[],options);

%%

[theta_matrix,comp_advg,pi]=extract_solution(solution,size_vector);

%%

[init_matrix,init_advg,init_pi]=extract_solution(init_sol_vec,size_vector);
