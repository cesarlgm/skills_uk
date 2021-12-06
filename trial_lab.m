clear
%trial lab
rng(100)
addpath('code/process_SES/','data');
skill_indexes=[3,4,8,6];
%%

%I generate individual level data.
n=1000;
scales=randi([1 5],n,21);
occ_index=randi([1 100],n,1);
educ_index=randi([1 3],n,1);
empshares=rand(289,1);

data=array2table(horzcat(educ_index,occ_index,ones(n,1),scales));

%%
%I extract the scales from my data
[skill_data,education_index,occ_index,n_skills,index_names]=extract_scale_data(data);

[skill_dummies,normalize_index]=create_scale_dummies(skill_data);

[scale_mult_matrix,scale_restriction_mat]=create_scaling_matrix(skill_dummies,skill_data);

parameter_vector=(1:84)';

error=error_wrapper(parameter_vector, ...
    normalize_index,skill_dummies,scale_mult_matrix,skill_indexes, ...
    n_skills,occ_index,education_index,empshares);
%%
[avg_use,grp]=average_skill_use(scales,occ_index,educ_index);

y=rand(size(avg_use,1),1);

beta_theta=estimate_beta_theta(y,avg_use,grp);