function MSE=compute_MSE(skill_sums,skill_sum_vector)
    n_obs=size(skill_sums,1);
    errors=skill_sums-skill_sum_vector;
    MSE=1/n_obs*(transpose(errors)*(errors));
end