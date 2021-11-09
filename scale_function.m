function out=scale_function(p,D,b,dummy_matrix,scale_matrix,restr_index)
    n_param=size(p,1);
    n_scale=sum(restr_index==0);
    n_obs=size(dummy_matrix,1);

   %Next step: I assign p with the required restrictions
   scale_param=p(1:n_scale,1);
   alpha_param=p(n_scale+1:n_param);

    r_scale_param=assign_parameters(scale_param,restr_index);   
 
    %The rescaled data matrix is then:
    rMatrix=dummy_matrix*diag(r_scale_param)*scale_matrix;

    
 
    %Create vector of restricted alphas
    r_alpha=D*alpha_param+b;

    error=rMatrix*r_alpha-ones(n_obs,1);
 
    
    out=1/n_obs*(transpose(error)*error);
end



   
   