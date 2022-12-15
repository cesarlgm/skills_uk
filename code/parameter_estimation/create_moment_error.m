%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create_moment_error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates the error vector for the GMM equation. 
% Functions it requires:
% -	create_linear_vector
% -	assign_thetas


function errors=create_moment_error(parameter_vector,y_var,s_matrix,size_vector,e1_dln_a_index,e1_educ_index,e3_a_index,e3n_educ_index,e3d_educ_index)

    %Step 1: Create the parameter vector

    l_parameters=create_linear_vector(parameter_vector,size_vector, ... 
        e1_dln_a_index,e1_educ_index,e3_a_index,e3n_educ_index,e3d_educ_index);
   

   %Step 2: Create the moment errors
   errors=y_var-s_matrix*l_parameters;
end