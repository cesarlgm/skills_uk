function variance_matrix=get_variance_matrix(z_matrix,V_matrix,data,size_vector,weighting,solution)
      n_instruments=size(z_matrix,2);
      n_parameters=size(solution,1);
      n_obs=size(data,1);

      %Step 1: set the weighting matrix
      if weighting==1
         W=  eye(n_instruments)/(transpose(z_matrix)*z_matrix);
      else
         W=eye(n_instruments);
      end

      %Step 2: get the gradient matrix estimate:
      xi_matrix=get_xi_matrix(data,size_vector,solution);
      size(xi_matrix);
      D_matrix=(1/n_obs)*transpose(z_matrix)*xi_matrix;
      size(z_matrix);

      %Step 3: get the bread
      bread_matrix=eye(n_parameters)/(transpose(D_matrix)*W*D_matrix);

      %Step 4: get the jelly
      jelly_matrix=transpose(D_matrix)*W*V_matrix*W*D_matrix;
    
      %Step 5: compute the variance matrix
      variance_matrix=bread_matrix*jelly_matrix*bread_matrix;
end