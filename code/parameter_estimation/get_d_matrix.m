function [d_theta,pi_vector]=get_d_matrix(parameter,z_matrix,sd_matrix,size_vector,e1_d_ln_a_index)
   
   %I split the vector of parameters into its components
   splitted_vector=assign_parameters(parameter,size_vector);

   %Assign theta and pi vector
   theta=splitted_vector{1};
   pi_vector=splitted_vector{2};
   
   %Get the full vector of pi parameters
   e1_full_pi=assign_thetas(pi_vector,e1_d_ln_a_index);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %RESHAPED PI VECTOR
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   reshaped_pi=reshape_pi_vector(e1_full_pi);

   %Next I compute the product of skill indexes and pi and the instruments
   zd_matrix=z_matrix(:,1:12);
    
   size(zd_matrix)
   size(sd_matrix)
   size(reshaped_pi)

   %First I compute the product of pi and the skill indexes
   d_theta=zd_matrix.*sd_matrix*reshaped_pi;
end