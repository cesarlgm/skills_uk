%this function takes the average skill use and computes the beta_theta
%vector

function beta=estimate_beta_theta(empshares,skill_index_avg,job_type_index)
    %STEP 1: I extract parameters to add the constant to the estimation
    n_obs=size(skill_index_avg,1);
    n_educ=length(unique(job_type_index));

    %STEP 2: I add column of ones to estimate the constant
    skill_index_avg=horzcat(ones(n_obs,1),skill_index_avg);

    %STEP 3: restructure the matrix to estimate different parameters for
    %each education level.
    S=educ_restructure(skill_index_avg,job_type_index);
    
    
    %STEP 4: erase the constants from the parameter estimates
    temp_beta=OLS(empshares,S);
    temp_beta=reshape(temp_beta,size(temp_beta,1)/n_educ,n_educ)' ; %matlab fills the reshape matrix by column
    temp_beta(:,1)=[];
    beta=temp_beta';
    beta=beta(:);
end