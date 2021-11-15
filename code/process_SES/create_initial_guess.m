function initial_guess=create_initial_guess(n_scales,n_skills,n_educ,...
      n_indexes)
    scale_0=1/n_scales*ones(n_scales,1);
    scale_weight_0=1/n_skills*ones(n_skills,1);
    index_weight_0=ones((n_indexes-1)*(n_educ-1),1);

    initial_guess=vertcat(scale_0,scale_weight_0,index_weight_0);
end