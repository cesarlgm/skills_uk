function [scale_vector,scale_weights,index_weights,sum_vector]=split_parameters(...
    parameter,n_skills,normalize_index,n_educ)
    n_scales=sum(normalize_index==0);
    n_alphas=n_skills;
    n_sum=n_educ-1;
    
    scale_vector=parameter(1:n_scales,1);
    scale_weights=parameter(n_scales+1:n_scales+n_alphas,1);
    sum_vector=parameter(n_scales+n_alphas+1:n_scales+n_alphas+n_sum,1);
    index_weights=parameter(n_scales+n_alphas+n_sum+1:end,1);
end