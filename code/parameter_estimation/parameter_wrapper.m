
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SETTING THE PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%%

options = optimoptions('fmincon','Display','iter','MaxIterations',3000,'MaxFunctionEvaluations',500000,'OptimalityTolerance',1e-6);

cd 'C:/Users/thecs/Dropbox (Boston University)/1_boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GETTING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_path="data/additional_processing/gmm_example_dataset_winsor.csv";
sol_path="data/additional_processing/initial_estimates.csv";

data=readtable(data_path);
init_sol=readtable(sol_path);
init_sol_vec=vertcat(table2array(init_sol(:,'parameter')),zeros(6,1));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EXTRACTING DATA FOR CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector,e1_dln_a_index,e1_educ_index, e1_code,e1_occ_index, ...
    lower_bound, upper_bound, e3_a_index,e3n_educ_index,e3d_educ_index, ...
    e3_occ_index]= extract_data_matrices(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EXTRACTING DATA FOR STANDARD ERRORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sd_matrix,z_indexes,i_indexes,sd2_matrix,num3s,den3s,...
    comparison,num_z,den_z,e3job_index]=extract_sd_matrix(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SETTING UP INITIAL VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Here I extract the solution I got in the previous 
load("code/parameter_estimation/current_state_three_eq.mat",'solution');

%%
eq1_param=sum(size_vector(1:2));
solution=solution(1:eq1_param);

%%

%From here I get initial conditions for the betas
splitted_vector=assign_parameters(solution,size_vector(1:2));
theta=splitted_vector{1};
pi=splitted_vector{2};

%%

%First I get the chi's I would have from simple OLS
chi_zero=get_beta_inv_zero(theta,pi,num3s,den3s,e3_a_index,e3n_educ_index,e3d_educ_index,e3job_index,y_matrix,comparison);
%%
get_chi=@(p)get_beta_inv_init(p,theta,pi,num3s,den3s,e3_a_index,e3n_educ_index,e3d_educ_index,e3job_index,y_matrix,comparison,num_z,den_z);

init_chi=fmincon(get_chi,chi_zero,[],[],[],[],[], ...
           [],[],options);


%%
initial_vector=vertcat(solution,init_chi);

%clear 'solution' 

sigma_init=ones(size(init_chi))./(1-init_chi);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANNONYMIZING THE FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error_solve=@(p)get_quadratic_form(p, z_matrix,y_matrix,s_matrix, ...
    size_vector,e1_dln_a_index,e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CONSTRAINING MANUAL TO BE THE SAME ACROSS ALL EDUCATION GROUPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_rest=zeros(2,n_total_parameters);
A_rest(:,1)=1;
A_rest(1,5)=-1;
A_rest(2,9)=-1;
b_rest=zeros(2,1);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SOLVE THE PROBLEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[solution,MSE]=fmincon(error_solve,initial_vector,[],[],A_rest,b_rest,lower_bound, [],[],options);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GET STANDARD ERRORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

[solution,MSE]=fmincon(error_solve,solution,[],[],A_rest,b_rest,lower_bound, [],[],options);

%[solution,MSE]=fmincon(error_solve,solution,[],[],[],[],lower_bound, [],[],options);


%%
load("code/parameter_estimation/current_solution.mat",'solution');

%%
[theta_matrix,comp_advg,pi,inv_sigma]=extract_solution(solution,size_vector);

sigma=1./(1-inv_sigma);

[se,V]=get_standard_errors(solution);



%%
pi_key=unique(data(data.equation==1,{'occupation','year','skill','ln_alpha'}));
pi_key=renamevars(pi_key,'ln_alpha','code');

[theta_table,pi_table]=write_parameter_table(solution,size_vector,pi_key);

writetable(pi_table,"data/output/pi_estimates.xlsx")
writetable(theta_table,"data/output/theta_estimates.xlsx")


%%

