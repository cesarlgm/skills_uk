clear;

rng(100);

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/process_SES/','data');

education='educ_3_low';
skill_indexes=[3,4,8,6];

%READING THE DATA
data=readtable('data/additional_processing/file_for_minimization.csv');


%%
%Renormalizing
%data.educ_3_low(data.educ_3_low==1)=4;
%data.educ_3_low(data.educ_3_low==3)=1;
%data.educ_3_low(data.educ_3_low==4)=3;

%%

%%
n_solutions=1;
tic
[solution_array,scale_array,alpha_array,s_weights_array,...
    MSE_array,index_matrix_array,sum_array]=solve_skill_problem(data,skill_indexes, ...
    n_solutions);
toc

%%
%Compute average of solutions
mean_MSE=mean(cell2mat(MSE_array));
sd_MSE=std(cell2mat(MSE_array));



 %%EXTRACTING THE RESULTS

writetable(scale_array{51},'results/tables/scale_matrix.xls','WriteRowNames',true)
writetable(alpha_array{51},'results/tables/weight_on_scales.xls')
writetable(s_weights_array{51},'results/tables/weight_on_indexes.xls','WriteRowNames',true)

s_weight_distance=zeros(n_solutions,1);
scale_distance=zeros(n_solutions,1);
alpha_distance=zeros(n_solutions,1);
for i=1:n_solutions
    dev=table2array(s_weights_array{i})-table2array(s_weights_array{n_solutions+1});
    s_weight_distance(i,1)=max(abs(dev(:)));

    dev=(table2array(alpha_array{i})-table2array(alpha_array{n_solutions+1}));
    alpha_distance(i,1)=max(abs(dev(:)));

    dev=(table2array(scale_array{i})-table2array(scale_array{n_solutions+1}));
    scale_distance(i,1)=max(abs(dev(:)));
end