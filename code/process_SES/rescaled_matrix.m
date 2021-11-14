function i_matrix=rescaled_matrix(dummy_matrix, ...
    ... %alpha_D,alpha_restr,
    solution,n_scale,restr_index,scale_matrix,skill_indexes)
   n_param=size(solution,1);
    
   %Next step: I assign p with the required restrictions
   scale_param=solution(1:n_scale,1);
   alpha_param=solution(n_scale+1:n_param);

   r_scale_param=assign_parameters(scale_param,restr_index);   

   %The rescaled data matrix is then:
   r_matrix=dummy_matrix*diag(r_scale_param)*scale_matrix;

   %Create vector of restricted alphas
   r_alpha=alpha_param;
   %r_alpha=alpha_D*alpha_param+alpha_restr;

   alpha_matrix=create_alpha_matrix(skill_indexes);

   i_matrix=r_matrix*diag(r_alpha)*alpha_matrix;
end
