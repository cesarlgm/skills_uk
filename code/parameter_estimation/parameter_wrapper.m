

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

[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector, ...
    e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index,lower_bound, ...
    upper_bound]= extract_data_matrices(data);

%%

error_solve=@(p)get_quadratic_form(p, z_matrix,y_matrix,s_matrix,size_vector,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);

%%

[solution,MSE]=fmincon(error_solve,init_sol_vec,[],[],[],[],lower_bound, ...
           upper_bound,[],options);

%%

[solution,MSE]=fmincon(error_solve,solution,[],[],[],[],lower_bound, ...
           upper_bound,[],options);

%%

[theta_matrix,comp_advg]=extract_solution(solution,size_vector);

%%

[init_matrix,init_advg]=extract_solution(init_sol_vec,size_vector);
