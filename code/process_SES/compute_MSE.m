function MSE=compute_MSE(skill_sums)
    errors=skill_sums-1;
    MSE=mean(transpose(errors)*errors);
end