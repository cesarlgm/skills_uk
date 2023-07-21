function [sigma,sigma_se, sigma_t_one,sigma_t_zero]=get_sigma(solution,se,size_vector)
  splitted_estimates=assign_parameters(solution,size_vector);
  splitted_se=assign_parameters(se,size_vector);

  beta_estimate=splitted_estimates{3};
  beta_se=splitted_se{3};

  sigma=1./(1-beta_estimate);
  sigma_se=abs(sigma).*beta_se;

  sigma_t_one=(sigma-1)./sigma_se;
  sigma_t_zero=(sigma)./sigma_se;
end