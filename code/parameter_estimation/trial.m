clear

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/parameter_estimation/','data');

education='educ_3_low';
index_composition=[3,4,8,6];

%READING THE DATA
skill_path='data/additional_processing/SES_file_theta_estimation.csv';
empshare_path='data/additional_processing/LFS_file_theta_estimation.csv';

restricted_weights=1;

%%
%STEP 1: I create all the 
[skill_data,skill_obs_tracker,n_skills,index_names]=extract_scale_data(skill_path);

[empshares,empshare_tracker]=extract_share_data(empshare_path);

%Compute number of scales in the data
n_scale_vector=count_n_scales(skill_data);

%STEP 2: create matrix of dummies for the scales
    % - In this step I also create an index indicating with scales are 
    %   normalized to zero (-1) and to (1).
[scale_dummies,normalize_index]=create_scale_dummies(skill_data);

%STEP 3: create the matrices of non-negativity restrictions 
[scale_mult_matrix,minimization_input]= ...
    create_scaling_matrix(scale_dummies,skill_data);

%%

%STEP 4: add weight normalizations if needed.
if restricted_weights==1
    alpha_restrictions=create_alpha_restrictions(index_composition);
else
    alpha_restrictions=[];
end

%% 

observation_trackers={skill_obs_tracker,empshare_tracker};

data={scale_dummies,scale_mult_matrix,empshares,skill_data};

computation_information={n_skills,index_composition,normalize_index,n_scale_vector,restricted_weights};


%%
n_weights=create_n_weights(index_composition,restricted_weights);

n_scales=sum(computation_information{3}==0);

old_scales=create_initial_guess(n_scales,n_weights,...
    1,computation_information{4});

%Step 1: split the vector into scales and weights
[scale_vector,scale_weights]=split_parameters(...
    old_scales,computation_information);


%%
%Step 2: I take the scale observations and compute skill indexes
skill_indexes=create_skill_index(scale_vector, ...
    scale_weights,data,computation_information,alpha_restrictions);


%%
%Write while loop here
tolerance=0.01;
max_iter=1000;
old_theta=new_theta;
old_scales=new_scales;
%old_theta=zeros(12,1);
deviation=1000;
n=0;

while (deviation>tolerance)&&(n<max_iter) 
   fprintf('Just started iteration #%d\n', n);

    %loop over thetas here

    %I just want a function that takes parameters and spits out a
    %theta
    [new_theta,job_type_index]=get_theta(old_scales, ...
        data, observation_trackers,computation_information);

    %Now I use that theta to estimate the scales
    new_scales=get_scales(new_theta,old_scales, data, ...
        computation_information,minimization_input,job_type_index);

    %update the loop trakers
    deviation=norm(new_theta-old_theta);
    deviation
    new_theta
    n=n+1;
    
    %update the parameters I search for
    old_scales=new_scales;
    old_theta=new_theta;
end

