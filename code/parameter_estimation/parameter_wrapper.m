%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: César Garro-Marín
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;

%SETTING THE PATHS
options = optimoptions('fmincon','Display','iter','MaxIterations',3000,'MaxFunctionEvaluations',500000,'OptimalityTolerance',1e-6);

cd 'C:/Users/thecs/Dropbox (Boston University)/1_boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');

%GETTING THE DATA
data_path="data/additional_processing/gmm_example_dataset_winsor.csv";
sol_path="data/additional_processing/initial_estimates.csv";

data=readtable(data_path);

n_obs=size(data,1);

%EXTRACTING DATA FOR THE CALCULATIONS
[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector,e1_dln_a_index,e1_educ_index, e1_code,e1_occ_index, ...
    lower_bound, upper_bound, e3_a_index,e3n_educ_index,e3d_educ_index, ...
    e3_occ_index]= extract_data_matrices(data);

%%
%SETTING UP INITIAL VALUES
%load("code/parameter_estimation/current_state_three_eq.mat",'solution');


%I annonymize the function
error_solve=@(p)get_quadratic_form(p, z_matrix,y_matrix,s_matrix, ...
    size_vector,e1_dln_a_index,e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);



%ADD RESTRICTIONS ON PI
n_pi_rest=size_vector(2)/4;

%I CONSTRAIN MANUAL COSTS TO BE THE SAME FOR ALL EDUCATION LEVELS
%The first two rows are the constraints on manual, the rest are the
%constraints on pi
A_rest=zeros(2+n_pi_rest,n_total_parameters);
A_rest(1:2,1)=1;
A_rest(1,5)=-1;
A_rest(2,9)=-1;

%Fill up the pi restrictions
for i=1:n_pi_rest
    A_rest(2+i,13+4*(i-1))=1;
end

b_rest=zeros(2+n_pi_rest,1);


%%

[solution,MSE]=fmincon(error_solve,solution,[],[],A_rest,b_rest,lower_bound, [],[],options);

%[solution,MSE]=fmincon(error_solve,solution,[],[],[],[],lower_bound, [],[],options);


%%
%Load the solution of needed
%load("code/parameter_estimation/current_solution_weighted.mat",'solution');
%load("code/parameter_estimation/current_solution_weighted_a1.mat",'solution');
%load("code/parameter_estimation/current_solution_weighted_a2.mat",'solution');
load("code/parameter_estimation/current_solution_weighted_a3.mat",'solution');
%%
%COMPUTE THE STANDARD ERRORS
v_estimate=estimate_v(solution,z_matrix,y_matrix,s_matrix,size_vector,...
    e1_dln_a_index, e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);


%%
variance_matrix=get_variance_matrix(z_matrix,v_estimate,data,size_vector,1,solution);

standard_errors=get_standard_errors(variance_matrix,n_obs);

[sigma_estimates,sigma_se,sigma_t_one, sigma_t_zero]=get_sigma(solution,standard_errors,size_vector);

%%


[standard_errors_matrix,~,~]=extract_solution(standard_errors,size_vector);


%%
%EXTRACT THE PARAMETERS
[theta_matrix,comp_advg,pi,inv_sigma]=extract_solution(solution,size_vector);




%%
pi_key=unique(data(data.equation==1,{'occupation','year','skill','ln_alpha'}));
pi_key=renamevars(pi_key,'ln_alpha','code');

beta_key=unique(data(data.equation==1,{'occupation'}));
%%
%%

[theta_table,pi_table,sigma_table]=write_parameter_table(solution,size_vector,pi_key,beta_key,standard_errors);
%%
dlnA=get_dlnA(pi_table,sigma_table);

%%
writetable(pi_table,"data/output/dlnA_estimates_threeeq.xlsx")
writetable(pi_table,"data/output/pi_estimates_threeeq.xlsx")
writetable(theta_table,"data/output/theta_estimates_threeeq.xlsx")
writetable(sigma_table,"data/output/sigma_estimates_threeeq.xlsx")



%%

