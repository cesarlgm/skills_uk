function standard_errors=get_standard_errors(variance_matrix,n_obs,size_vector,n_skills)
    
    temporary=sqrt(diag((1/n_obs)*variance_matrix));

    n_param=sum(size_vector);
    standard_errors=zeros(n_param,1);
   
    standard_errors([1,5,9])=temporary(1);
    standard_errors(2:4)=temporary(2:4);
    standard_errors(6:8)=temporary(5:7);
    standard_errors(10:12)=temporary(8:10);

    index_vector=1:n_param;

    %Assigning the pis
    standard_errors(mod(index_vector,n_skills)~=1&index_vector>12)=temporary(11:end);
end