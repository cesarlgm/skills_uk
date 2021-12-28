clear
%trial lab
rng(100)

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/process_SES/','data','code/parameter_estimation/');
skill_composition=[3,4,8,6];

skill_path='data/additional_processing/SES_file_theta_estimation.csv';
empshare_path='data/additional_processing/LFS_file_theta_estimation.csv';
%% 




% %%
% 
% %I generate individual level data.
% n=1000;
% scales=randi([1 5],n,21);
% occ_index=randi([1 100],n,1);
% educ_index=randi([1 3],n,1);

%%
[skill_data,skill_obs_tracker,n_skills,index_names]=extract_scale_data(skill_path);

[empshares,empshare_tracker]=extract_share_data(empshare_path);

%Compute number of scales in the data
n_scale_vector=count_n_scales(skill_data);

%STEP 2: create matrix of dummies for the scales
    % - In this step I also create an index indicating with scales are 
    %   normalized to zero (-1) and to (1).
[scale_dummies,normalize_index]=create_scale_dummies(skill_data);

%STEP 3: create the matrices of non-negativity restrictions 
[scale_mult_matrix,scale_restriction_mat]= ...
    create_scaling_matrix(scale_dummies,skill_data);

observation_trackers={skill_obs_tracker,empshare_tracker};

data={scale_dummies,scale_mult_matrix,empshares,skill_data};

computation_information={n_skills,skill_composition,normalize_index};


[solution_array,scale_array,alpha_array,theta_array, ...
    theta_matrix_array,skill_index_array,MSE_array]= ...
    solve_skill_problem(skill_path,empshare_path,skill_composition,1);