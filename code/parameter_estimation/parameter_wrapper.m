
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
    e1_occ_index,lower_bound, upper_bound,aweight_matrix]= extract_data_matrices(data,n_skills);

%Here I extract information necessary to compute the standard errors
gradient_matrix=extract_se_data(data);



%%

A_rest=zeros(4,n_total_parameters);
A_rest(1,1)=1;
A_rest(2,n_skills+1)=1;
A_rest(3,2*n_skills+1)=1;
A_rest(4,size_vector(1)+size_vector(2)+1)=1;
% 
b_rest=ones(4,1);
b_rest(4,1)=-1;


%%
initial_sol=zeros(n_total_parameters,1);
initial_sol(1:12)=1;
initial_sol(size_vector(1)+size_vector(2)+1:end,1)=-1;


%%

error_solve=@(p)get_quadratic_form(p,y_matrix,size_vector,e1_dln_a_index,e1_theta_code,e1_theta_code_den,e1_occ_index,aweight_matrix,1);


%%
[solution,MSE,~,~,lambda,a_grad,a_hessian]=fmincon(error_solve,initial_sol,[],[],A_rest,b_rest,lower_bound, upper_bound,[],options);

%%
[solution,MSE,~,~,lambda,a_grad,a_hessian]=fmincon(error_solve,solution,[],[],A_rest,b_rest,lower_bound, upper_bound,[],options);


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
%load('./code/parameter_estimation/hail_mary_solution.mat','solution')
%%
load('./code/parameter_estimation/current_solution_eq6.mat','solution')

error1=error_solve(solution);

%%
load('./code/parameter_estimation/current_solution_eq6_bad_norm.mat','solution')

error2=error_solve(solution);
%%
%Computation of standard errors
variance_matrix=get_variance_matrix(solution, size_vector, y_matrix,e1_dln_a_index,e1_occ_index,e1_theta_code,e1_theta_code_den,gradient_matrix,aweight_matrix);

%%
standard_errors=get_standard_errors(variance_matrix,size_vector);

%%
%Extracting information from all the parameters
[theta_matrix,comp_advg,pi,sigma]=extract_solution(solution,size_vector,n_skills);

[standard_error_matrix,~,~,~]=extract_solution(standard_errors,size_vector,n_skills);


%%
%Checking number of bs that significantly positive
[n_positive_bs,significant_positive,positive_bs,t_stat_bs]=get_n_positive_bs(solution,standard_errors,size_vector);



%%
%Estimate whether the \thetas are different across education groups
[f_stats,p_values]=compute_f_stats(solution,variance_matrix);

%%
%Identifying and writing estimates

dlna_key=unique(data(data.equation==1,{'occupation','year','skill','ln_alpha'}));
dlna_key=renamevars(dlna_key,'ln_alpha','code');

b_key=unique(data(data.equation==1,{'occupation','job_index'}));

[theta_table,dlna_table,b_table]=write_parameter_table(solution,size_vector,dlna_key,b_key,standard_errors);


writetable(dlna_table,"data/output/dlna_estimates_eq6.xlsx")
writetable(b_table,"data/output/b_estimates_eq6.xlsx")
writetable(theta_table,"data/output/theta_estimates_eq6.xlsx")

