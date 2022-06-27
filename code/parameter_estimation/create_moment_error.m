function errors=create_moment_error(parameter_vector,y_var,s_matrix, ...
    size_vector,e1_indexes,e3_indexes)
    
    %Step 1: Create the parameter vector
    l_parameters=create_linear_vector(parameter_vector,size_vector, ... 
        e1_indexes, e3_indexes);
    
   %Step 2: Create the moment errors
   errors=y_var-s_matrix*l_parameters;
end