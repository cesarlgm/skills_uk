function standard_errors=get_standard_errors(variance_matrix,n_obs,size_vector,n_skills)
    
    temporary=sqrt(diag((1/n_obs)*variance_matrix));

    n_param=sum(size_vector);
    standard_errors=zeros(n_param,1);

    index_vector=1:n_param;

    %Assigning the pis
    standard_errors(1:12)=temporary(1:12);
    standard_errors(mod(index_vector,n_skills)~=1&index_vector>12)=temporary(13:end);
end