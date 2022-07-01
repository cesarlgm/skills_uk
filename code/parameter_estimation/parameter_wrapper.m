clear

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';
addpath('code/parameter_estimation/','data');


data_path="data/additional_processing/gmm_example_dataset.csv";
%% 

data=readtable(data_path);
    

[z_matrix,y_matrix,s_matrix,n_total_parameters,size_vector,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index]=extract_data_matrices(data);

%%

%Vector for trying things
trial_vector=transpose(1:n_total_parameters);


%%
e_vector=get_quadratic_form(trial_vector,z_matrix,y_matrix,s_matrix,size_vector,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);


