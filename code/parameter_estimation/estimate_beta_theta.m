%this function takes the average skill use and computes the beta_theta
%vector

function [beta,obs_tracker,job_type_index]=estimate_beta_theta(deviations)
    %I haven't made sure that the data is in the right order

    %STEP 1: I extract data I require for the regressions
    empshares=table2array(deviations{2}(:,4:end));
    obs_tracker=deviations{1}(:,1:3);
    
    skill_deviations=table2array(deviations{1}(:,4:end));
    job_type_index=table2array(deviations{1}(:,'job_type'));
    
    n_obs=size(skill_deviations,1);
    n_educ=length(unique(job_type_index));

 % Constant no longer included in the estimation
 %   %STEP 2: I add column of ones to estimate the constant
 %  skill_deviations=horzcat(ones(n_obs,1),skill_deviations);

    %STEP 3: restructure the matrix to estimate different parameters for
    %each education level.
    S=educ_restructure(skill_deviations,job_type_index);
    
    
    %STEP 4: erase the constants from the parameter estimates
    temp_beta=OLS(empshares,S);
    temp_beta=reshape(temp_beta,size(temp_beta,1)/n_educ,n_educ)' ; %matlab fills the reshape matrix by column
    
    %Uncomment this line if constant has to be included
    %temp_beta(:,1)=[];
    beta=temp_beta';
    beta=beta(:);
end