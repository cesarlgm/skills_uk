function [scale_vector,scale_weights]=split_parameters(...
    parameter,computation_information)

    n_skills=computation_information{1};
    
    normalize_index=computation_information{3};

    n_scales=sum(normalize_index==0);
    n_alphas=n_skills;
    
    scale_vector=parameter(1:n_scales,1);
    scale_weights=parameter(n_scales+1:n_scales+n_alphas,1);
end

