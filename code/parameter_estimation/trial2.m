

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SETTING THE PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%%

options = optimoptions('fmincon','Display','iter','MaxIterations',3000,'MaxFunctionEvaluations',2000000);

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GETTING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_path="data/additional_processing/gmm_example_dataset.csv";
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

%%%
%GET INITIAL VALUES FOR BETA_INV
%%%

initial_vector=transpose(1:44);

%%
error=create_moment_error(solution,y_matrix,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);



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
[solution,MSE]=fmincon(error_solve,initial_vector,[],[],A_rest,b_rest,lower_bound, upper_bound,[],options);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GET STANDARD ERRORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[se,V]=get_standard_errors(solution);

%%

[solution,MSE]=fmincon(error_solve,solution,[],[],A_rest,b_rest,lower_bound, upper_bound,[],options);

%%

[theta_matrix,comp_advg,pi]=extract_solution(solution,size_vector);

%%

[init_matrix,init_advg,init_pi]=extract_solution(init_sol_vec,size_vector);
