%%Checking whether algorithm works
clear

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/parameter_estimation/','data');

index_composition=[1,1,3,1];

%READING THE DATA
skill_path='data/additional_processing/sim_skill.csv';
empshare_path='data/additional_processing/sim_emp.csv';

%%
%First I extract the simulated data
[skill_data,skill_obs_tracker,n_skills,index_names]=extract_scale_data(skill_path);

[empshares,empshare_tracker]=extract_share_data(empshare_path);

%%
%Compute number of scales in the data
n_scale_vector=count_n_scales(skill_data);

%%
%STEP 2: create matrix of dummies for the scales
    % - In this step I also create an index indicating with scales are 
    %   normalized to zero (-1) and to (1).
[scale_dummies,normalize_index]=create_scale_dummies(skill_data);

%%
%STEP 3: create the matrices of non-negativity restrictions 
[scale_mult_matrix,minimization_input]= ...
    create_scaling_matrix(scale_dummies,skill_data);

%%
observation_trackers={skill_obs_tracker,empshare_tracker};

data={scale_dummies,scale_mult_matrix,empshares,skill_data};

computation_information={n_skills,index_composition,normalize_index,n_scale_vector};

%%
old_scales=create_initial_guess(2,2,1,computation_information{4});

%%

%Step 1: split the vector into scales and weights
[scale_vector,scale_weights]=split_parameters(...
    old_scales,computation_information);

%%
%Step 2: I take the scale observations and compute skill indexes
skill_indexes=create_skill_index(scale_vector, ...
    scale_weights,data,computation_information);

%%
%Write while loop here
TOLERANCE=1e-100;
MAX_ITER=100;
old_theta=zeros(4,1);
new_theta=ones(4,1);
new_scales=zeros(4,1);
deviation=1000;
n=1;

while (deviation>TOLERANCE)&&(n<MAX_ITER) 
   fprintf('Just started iteration #%d\n', n);

    %I just want a function that takes parameters and spits out a
    %theta
    [new_theta,job_type_index,regression_data]=get_theta(old_scales, ...
        data, observation_trackers,computation_information);

    %Now I use that theta to estimate the scales
    new_scales=get_scales(new_theta,old_scales, data, ...
        computation_information,minimization_input,job_type_index);

    %update the loop trakers
    deviation=norm(new_theta-old_theta);

    n=n+1;
    
    %update the parameters I search for
    old_scales=new_scales;
    old_theta=new_theta;
end


[scale_vector,scale_weights]=split_parameters(...
    new_scales,computation_information);
