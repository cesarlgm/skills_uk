function MSE=compute_MSE(skill_sums)
    n_obs=size(skill_sums,1);
    errors=skill_sums-1;
    MSE=1/n_obs*(transpose(errors)*(errors));
end