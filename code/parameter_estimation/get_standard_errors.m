function standard_errors=get_standard_errors(variance_matrix,n_obs)
    
    temporary=sqrt(diag((1/n_obs)*variance_matrix));

    n_param=size(temporary,1)+2;
    standard_errors=zeros(n_param,1);
    
    standard_errors(13:end)=temporary(11:end);
    standard_errors([1,5,9])=temporary(1);
    standard_errors(2:4)=temporary(2:4);
    standard_errors(6:8)=temporary(5:7);
    standard_errors(10:12)=temporary(8:10);
end