clear;

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/process_SES/','data');

education='educ_3_low';
skill_indexes=[3,4,8,6];

%READING THE DATA
data=readtable('data/additional_processing/file_for_minimization.csv');


%%
trial=solve_skill_problem(data,skill_indexes);

%%
%%EXTRACTING THE RESULTS

[scale_matrix,alpha_vec,s_weights]=extract_solution_data(data,skill_indexes,scale_solution,weights,n_educ);

writetable(scale_matrix,'results/tables/scale_matrix.xls','WriteRowNames',true)
writetable(alpha_vec,'results/tables/weight_on_scales.xls')
writetable(s_weights,'results/tables/weight_on_indexes.xls','WriteRowNames',true)
