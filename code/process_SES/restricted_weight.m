%possible correction to eliminate observations of low skill group 
function [rwgt,n_educ]=restricted_weight(weights,n_skills)
    n_weights=size(weights,1);

    %setting the weight parameters
    n_educ=(n_weights/(n_skills-1))+1;

    %rest of weights
    w_end=reshape(weights(1:n_weights),n_skills-1,n_educ-1);

    rwgt=reshape(vertcat([1,1],w_end),n_skills*(n_educ-1),1);
end