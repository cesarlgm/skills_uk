%wrapper of theta estimation
function theta=theta_wrapper(empshares,skill_indexes,occ_index,job_type_index)
    %Step 1: I compute the skill indexes out the scales

    %Step 2: I compute average skill use by type 
    [skill_job_use,job_type]=average_skill_use(skill_indexes,occ_index,job_type_index);

    %STEP 3: estimate beta
    beta=estimate_beta_theta(empshares,skill_job_use,job_type);

    %STEP 4: estimate theta
    theta=estimate_theta(beta,job_type);
end