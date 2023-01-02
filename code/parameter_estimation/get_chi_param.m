function init_chi_vector=get_chi_param(vector,size_vector)
   splitted_vector=assign_parameters(vector,size_vector);

   chi_vector=splitted_vector{3};
   comp_vector=splitted_vector{4};

   init_chi_vector=vertcat(chi_vector,comp_vector);
end