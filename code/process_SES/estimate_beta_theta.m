%this function takes the average skill use and computes the beta_theta
%vector

function beta=estimate_beta_theta(empshares,skill_index_avg,job_type_index)
    S=educ_restructure(skill_index_avg,job_type_index);
    beta=OLS(empshares,S);
end