function MSE=theta_error(skill_indexes,theta,job_type_index)
    %Compute number of observations in the data
    observations=1/size(skill_indexes,1);
    
    %Compute big S
    S=educ_restructure(skill_indexes,job_type_index);

    error=S*theta-1;
    
    %Compute MSE
    MSE=(1/observations)*(error'*error);
end