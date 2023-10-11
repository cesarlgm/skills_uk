%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: César Garro-Marín
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function computes variance matrix \bar{V}

function variance_matrix=get_variance_matrix(z_matrix,y_matrix,s_matrix,data, ...
      size_vector,weighting,solution, n_skills,e1_dln_a_index,e1_educ_index,...
      e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index)
      n_instruments=size(z_matrix,2);
      n_parameters=size(solution,1);
      n_obs=size(data,1);
      n_pi_dropped=size_vector(2)/n_skills;

      %I first set up the weighting matrix
      if weighting==1
         A=  eye(n_instruments)/(transpose(z_matrix)*z_matrix);
      else
         A=eye(n_instruments);
      end

      %Next compute the \Xi matrix
      xi_matrix=get_xi_matrix(data,size_vector,solution,n_skills);
    
      %And then comute \hat{D}
      D_matrix=(1/n_obs)*transpose(z_matrix)*xi_matrix;
    
      V_matrix=estimate_v(solution,z_matrix,y_matrix,s_matrix,size_vector,...
            e1_dln_a_index, e1_educ_index,e3_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);

      %I compute "bread": the matrix (\hat{D}'A\hat{D})^-1
      bread_matrix=eye(n_parameters-2-n_pi_dropped)/(transpose(D_matrix)*A*D_matrix);

      %Computing the "jelly": \hat{D}'A\hat{V}A\hat{D}
      jelly_matrix=transpose(D_matrix)*A*V_matrix*A*D_matrix;
    
      %I finising by creating the sandwich
      variance_matrix=bread_matrix*jelly_matrix*bread_matrix;
end