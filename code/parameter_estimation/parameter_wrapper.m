



%% 
    
clear;

%Setting the number of skills in the data

n_skills=4;



%READING DATA

options = optimoptions('fmincon','Display','iter','MaxIterations',3000,'MaxFunctionEvaluations',2000000);



cd 'C:/Users/thecs/Dropbox/1_boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');

data_path="data/additional_processing/gmm_example_dataset_eq6_a2.csv";


data=readtable(data_path);


n_obs=size(data,1);


%%
%Here I extract all the information that I need for the estimation
[y_matrix,n_total_parameters,size_vector,e1_dln_a_index, e1_theta_code, e1_theta_code_den, ...
    e1_occ_index,lower_bound, upper_bound]= extract_data_matrices(data,n_skills);

%Here I extract information necessary to compute the standard errors
gradient_matrix=extract_se_data(data);

%%

A_rest=zeros(3,n_total_parameters);
A_rest(1,1)=1;
A_rest(2,n_skills+1)=1;
A_rest(3,2*n_skills+1)=1;
% 
b_rest=ones(3,1);


%%
initial_sol=zeros(n_total_parameters,1);
initial_sol(1:12)=1;
initial_sol(1107:end,1)=-1;


%%

error_solve=@(p)get_quadratic_form(p,y_matrix,size_vector,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index);


%%
[solution,MSE]=fmincon(error_solve,initial_sol,[],[],A_rest,b_rest,lower_bound, upper_bound,[],options);


%%
save('./code/parameter_estimation/hail_mary_solution.mat','solution')


%%
%Importing solution of the algorithm
%load("code/parameter_estimation/current_solution_twoeq_a1.mat",'solution');
%load("code/parameter_estimation/current_solution_twoeq_a3.mat",'solution');
%load("code/parameter_estimation/current_solution_twoeq_a2.mat",'solution');
%load("code/parameter_estimation/current_solution_twoeq_a2_diff_manual.mat",'solution');


%load("code/parameter_estimation/current_solution_twoeq_a2_noabstract.mat",'solution');
%load("code/parameter_estimation/current_solution_twoeq_a2_noroutine.mat",'solution');
load('./code/parameter_estimation/hail_mary_solution.mat','solution')

%%

%Extracting information from all the parameters
[theta_matrix,comp_advg,pi,sigma]=extract_solution(solution,size_vector,n_skills);

%%
gradient=compute_gradient(solution,gradient_matrix,size_vector,y_matrix,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index);

%%
%Computation of standard errors
variance_matrix=get_variance_matrix(z_matrix,y_matrix,s_matrix,data,...
     size_vector,1,solution,n_skills,e1_dln_a_index,e1_educ_index);

%%
pi_key=unique(data(data.equation==1,{'occupation','year','skill','ln_alpha'}));
pi_key=renamevars(pi_key,'ln_alpha','code');

[theta_table,pi_table]=write_parameter_table(solution,size_vector,pi_key,standard_errors);


%%

%%
standard_errors=get_standard_errors(variance_matrix,n_obs,size_vector,n_skills);


%%
[standard_errors_matrix,~,~]=extract_solution(standard_errors,size_vector,n_skills);

%%
a=estimate_v(solution,y_matrix,...
    size_vector,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index);

%%
%%Finally I create theta and pi tables to handle in Stata
pi_key=unique(data(data.equation==1,{'occupation','year','skill','ln_alpha'}));
pi_key=renamevars(pi_key,'ln_alpha','code');

[theta_table,pi_table]=write_parameter_table(solution,size_vector,pi_key,standard_errors);

%%
writetable(pi_table,"data/output/pi_estimates_twoeq.xlsx")
writetable(theta_table,"data/output/theta_estimates_twoeq.xlsx")

%%
