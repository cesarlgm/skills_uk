%%GENERATING DATA FROM THE MODEL TO CHECK WHETHER IT WORKS
%START WITH THE SIMPLEST POSSIBLE MODEL

%2 education, 2 skills, 2 variables

%%
clear

cd 'C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData';

addpath('code/parameter_estimation/','data');

education='educ_3_low';

rng(100)

%%
%Parameters of the problem

%Size parameters
n_obs=10;
n_educ=2;
n_jobs=10000;

%Probabilities:
p_2=[1/8,7/8];


%Coefficients of empshare equation
epsilon=.5;
dlnA=[3,-2;3,-2];
K=2*ones(2,2);
theta=[1,1;1,.5];

emp_coef=(epsilon/(1-epsilon))*theta.*(dlnA-K);


skill_data=simulate_skill_data(theta(:,2),p_2,n_jobs,n_obs);


%%

[empshare_data,skill_averages]=simulate_emp(skill_data,emp_coef);

skill_averages=array2table(skill_averages);
empshare_data=array2table(empshare_data);

%%
skill_averages=renamevars(skill_averages,["skill_averages2"],["job_type"]);

%% 
%%
deviations=cell(2,1);
deviations{1}=sortrows(skill_averages, ...
        {'job_type' 'skill_averages1' 'skill_averages3'});
%This line outputs the empshare data. No averages needed.
deviations{2}=sortrows(empshare_data, ...
        {'empshare_data2' 'empshare_data1' 'empshare_data3' });

%%

beta_theta=estimate_beta_theta(deviations);
%%
theta=estimate_theta(beta_theta,[1;2]);
%%
skill_data=array2table(skill_data);
skill_data=renamevars(skill_data,["skill_data1","skill_data2","skill_data3"],...
    ["occupation","education","year"]);


empshare_data=renamevars(empshare_data,["empshare_data1","empshare_data2","empshare_data3","empshare_data4"]...
    ,["occupation","education","year","d_l_educ_empshare"]);
%%
%Writing simulated data into disk
writetable(skill_data,'data/additional_processing/sim_skill.csv');
writetable(empshare_data,'data/additional_processing/sim_emp.csv');