function standard_errors=get_standard_errors(variance_matrix,size_vector)
    
    temporary=sqrt(diag(variance_matrix));

    size_vector_adj=size_vector;
    size_vector_adj(1)=size_vector_adj(1)-3;

    n_param=sum(size_vector);
    
    standard_errors=zeros(n_param,1);

    standard_errors([2:4,6:8,10:12])=temporary(1:9);
    standard_errors(13:end)=temporary(10:end);
end