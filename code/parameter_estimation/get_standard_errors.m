function standard_errors=get_standard_errors(variance_matrix,n_obs)
    
    standard_errors=sqrt(diag((1/n_obs)*variance_matrix));
end