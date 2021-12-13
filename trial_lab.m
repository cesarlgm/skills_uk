clear
%trial lab
rng(100)

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/process_SES/','data','code/parameter_estimation/');
skill_indexes=[3,4,8,6];
%%

%I generate individual level data.
n=1000;
scales=randi([1 5],n,21);
occ_index=randi([1 100],n,1);
educ_index=randi([1 3],n,1);


[a,b,c]=compute_deviation(scales,occ_index,educ_index);
%%

empshares=rand(289,1);

g=findgroups(occ_index)
b=splitapply(@mean,scales,g);
%%

data=array2table(horzcat(educ_index,occ_index,ones(n,1),scales));
%%

%I extract the scales from my data
[a,b,c,d,e,f]=solve_skill_problem(data,empshares,skill_indexes,1);