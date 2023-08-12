

%%
clear;

%%READING DATA

options = optimoptions('fmincon','Display','iter','MaxIterations',3000,'MaxFunctionEvaluations',2000000);



cd 'C:/Users/thecs/Dropbox (Boston University)/1_boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');

data_path="data/additional_processing/gmm_example_dataset_twoeq.csv";


data=readtable(data_path);


n_obs=size(data,1);

[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector,e1_dln_a_index,e1_educ_index, e1_code, ...
    lower_bound, upper_bound]= extract_data_matrices(data);

%Constraining manual to be the same
A_rest=zeros(2,n_total_parameters);
A_rest(:,1)=1;
A_rest(1,5)=-1;
A_rest(2,9)=-1;
b_rest=zeros(2,1);

%%
%Importing solution from GMM equation
load("code/parameter_estimation/restricted_gmm_new.mat",'solution');

initial_sol=solution;
clear solution


error_solve=@(p)get_quadratic_form(p, z_matrix,y_matrix,s_matrix,size_vector,e1_dln_a_index,e1_educ_index);


[solution,MSE]=fmincon(error_solve,initial_sol,[],[],A_rest,b_rest,lower_bound, upper_bound,[],options);



%%
%Importing solution of the algorithm
%load("code/parameter_estimation/current_solution_twoeq_a1.mat",'solution');
%load("code/parameter_estimation/current_solution_twoeq_a2.mat",'solution');
load("code/parameter_estimation/current_solution_twoeq_a3.mat",'solution');
[theta_matrix,comp_advg,pi]=extract_solution(solution,size_vector);


%%
v_estimate=estimate_v(solution,z_matrix,y_matrix,s_matrix,size_vector,...
    e1_dln_a_index, e1_educ_index);

%%
variance_matrix=get_variance_matrix(z_matrix,v_estimate,data,size_vector,1,solution);
%%
standard_errors=get_standard_errors(variance_matrix,n_obs);
[standard_errors_matrix,~,~]=extract_solution(standard_errors,size_vector);



%%
%%Finally I create theta and pi tables to handle in Stata
pi_key=unique(data(data.equation==1,{'occupation','year','skill','ln_alpha'}));
pi_key=renamevars(pi_key,'ln_alpha','code');

[theta_table,pi_table]=write_parameter_table(solution,size_vector,pi_key,standard_errors);

writetable(pi_table,"data/output/pi_estimates_twoeq.xlsx")
writetable(theta_table,"data/output/theta_estimates_twoeq.xlsx")

%%
