clear;

rng(100);

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/process_SES/','data');

education='educ_3_low';
skill_indexes=[3,4,8,6];

%READING THE DATA
data=readtable('data/additional_processing/file_for_minimization.csv');


%%
n_solutions=50;
tic
[solution_array,scale_array,alpha_array,s_weights_array,...
    MSE_array,index_matrix_array]=solve_skill_problem(data,skill_indexes, ...
    n_solutions);
toc

% %%
% %%EXTRACTING THE RESULTS
% 
% writetable(scale_matrix,'results/tables/scale_matrix.xls','WriteRowNames',true)
% writetable(scale_weights,'results/tables/weight_on_scales.xls')
% writetable(index_weights,'results/tables/weight_on_indexes.xls','WriteRowNames',true)
