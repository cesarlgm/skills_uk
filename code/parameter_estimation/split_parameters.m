%This function splits the parameter vector into scales and 
%weights
function [scale_vector,scale_weights]=split_parameters(...
    parameter,computation_information)
    
    %flag indicating whether weights are restricted to sum to one
    restricted_weights=computation_information{5};

    %Get the appropriate number of alphas I need
    n_alphas=create_n_weights(computation_information{2},restricted_weights);


    %Net I get the number of scales in the vector
    normalize_index=computation_information{3};
    n_scales=sum(normalize_index==0);

 
    %Finally I use the above information to split the vector into scales
    %and weights
    scale_vector=parameter(1:n_scales,1);
    scale_weights=parameter(n_scales+1:n_scales+n_alphas,1);
end

