clear

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');


data_path="data/additional_processing/gmm_example_dataset.csv";

data=readtable(data_path);

%Extracting y_var vector
y_var=get_y_var(data);
s_matrix=get_s_matrix(data);




%%
%Defining number of parameters I need to compute:
n_ln_A_raw=max(table2array(data(:,"ln_alpha")));
n_ln_A_effective=max(table2array(data(:,"ln_alpha")))*.75;
n_sigma=max(table2array(data(:,"occ_id")));
n_theta=12;
n_comparison=max(table2array(data(:,"ee_group_id")));
n_total_parameters=n_sigma+n_theta+n_ln_A_effective+n_comparison;


trial_vector=transpose(1:n_total_parameters);


%order of parameter: theta ln_A sigma, eta
size_vector=[n_theta;n_ln_A_effective;n_sigma;n_comparison];


%% 
[e1_d_ln_a_index, e1_occ_index,e1_educ_index, ...
    e3_a_index,e3n_educ_index,e3d_educ_index,e1_code,e3_code]=get_occ_indexes(data);
 
%%
new=create_moment_error(trial_vector,y_var,s_matrix,size_vector,e1_occ_index, ... 
    e1_educ_index,e1_d_ln_a_index,e3_a_index, ... 
    e3n_educ_index,e3d_educ_index)
  
%%
create_linear_vector(trial_vector,size_vector,e1_occ_index, ... 
    e1_educ_index,e1_d_ln_a_index,e3_a_index, ... 
    e3n_educ_index,e3d_educ_index);


%Next thing I need to do, is construct matrix of Z's
%Write the quatractic form

%Write code for standard errors.
