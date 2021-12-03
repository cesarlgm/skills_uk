%trial lab
rng(100)
n=1000;
occ_index=randi([1 100],n,1);
educ_index=randi([1 3],n,1);
skill_indexes=rand(n,4);

addpath('code/process_SES/','data');

education='educ_3_low';

[avg_use,grp]=average_skill_use(skill_indexes,occ_index,educ_index);

y=rand(size(avg_use,1),1);

beta_theta=estimate_beta_theta(y,avg_use,grp);