%function estimates square error
function error_weights=square_error_wg(weights,data,n_skills)

    %get the vector of weights with the imposed restrictions
    r_weight=restricted_weight(weights,n_skills);
    
    %Getting total number of observations
    n_obs=size(data,1);
    
    
    moment=(data*r_weight-ones(n_obs,1));
    
    error_weights=(transpose(moment)*moment)/n_obs;
end