%square_error

function sq_error=square_error(data,parameters)
    %occupations
    [occ,jj,kk]=unique(data(:,1)) 

    n_param=length(parameters);
    x=dummyvar(data); 
    z=tril(ones(n_param+1));
    
    a=vertcat(eye(n_param),-1*ones(1,n_param));
    r=vertcat(zeros(n_param,1),1);
    
    x_size=size(x,1);
   
    restriction=ones(x_size,1);
    
    b=x*z;
  
    error=b*(a*diag(parameters)*parameters-r)-restriction;
    
    sq_error=transpose(error)*error;
end