
function errors=create_moment_error_norest(parameter_vector,y_var,s_matrix,size_vector,e1_dln_a_index,e1_educ_index)

    %Step 1: Create the parameter vector

    l_parameters=create_linear_vector_norest(parameter_vector,size_vector, ... 
        e1_dln_a_index,e1_educ_index);
   

   %Step 2: Create the moment errors
   errors=y_var-s_matrix*l_parameters;
end