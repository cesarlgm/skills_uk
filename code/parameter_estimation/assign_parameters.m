%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%assign_parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes the vector of parameters in the model and splits them by parameter type.


%Log of latest modifications
%Latest modifications: none
function result=assign_parameters(parameters,size_vector)
    result=mat2cell(parameters,size_vector,1);
end