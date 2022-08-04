%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign_thetas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes the vector of thetas and creates a vector the size of educ_index. Theta parameters are assigned according to the positions indicated in educ_index.

function result=assign_thetas(theta, educ_index)
    result=theta(educ_index,1);
end