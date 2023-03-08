

%Creating linear vector
function [theta_table,pi_table]=write_parameter_table(parameter,size_vector,pi_key) %e1_d_ln_a_index,e1_educ_index)
    
splitted_vector=assign_parameters(parameter,size_vector);

    %I extract the theta estimates
    theta=splitted_vector{1};

    %First I create the theta table
    theta_table=create_theta_table(theta);
  
    %Next, I create the pi table
    pi_vector=splitted_vector{2};
    
    pi_table=create_pi_table(pi_vector, pi_key);
    
end