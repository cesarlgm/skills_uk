%hessian computation
function hessian=get_hessian_obs(parameter_vector,size_vector,e1_dln_a_index,e1_job_index,e1_theta_code,obs,errors)

    %I four blocks
    size_vector_adj=size_vector;
    size_vector_adj(1)=size_vector_adj(1)-3;

    splitted_vector=assign_parameters(parameter_vector,size_vector);
    theta=splitted_vector{1};
    ds=splitted_vector{2};
    bs=splitted_vector{3};

    n_theta=size_vector_adj(1);
    n_D=size_vector_adj(2);
    n_b=size_vector_adj(3);
    n_total_parameters=sum(size_vector_adj);

    %Create the full matrix
    hessian=zeros(n_total_parameters,n_total_parameters);

    %Assigning DD block
    m=e1_dln_a_index(obs);
    hessian(n_theta+m,n_theta+m)=-1;
    
    %Assigning bb_block
    j=e1_job_index(obs);
    obs_theta=theta(e1_theta_code(obs));
    hessian(n_theta+n_D+j,n_theta+n_D+j)=-(log(obs_theta))^2;

    %Assigning the bD blocks
    hessian(n_theta+n_D+j,n_theta+m)=-log(obs_theta);
    hessian(n_theta+m,n_theta+n_D+j)=-log(obs_theta);

    %Assigning the \theta D block
    i=e1_theta_code(obs);
    if (i>4)&&(i<=8)
        i=i-2;
    elseif i>8
        i=i-3;
    else
        i=i-1;
    end

    obs_b=bs(e1_job_index(obs));
    hessian(n_theta+m,i)=(-1*obs_b)/obs_theta;
    hessian(i,n_theta+m)=(-1*obs_b)/obs_theta;

    %Assigning theta by theta block
    obs_error=errors(obs);
    hessian(i,i)=-(obs_b/(obs_theta)^2)*(obs_error+obs_b);

    %Assigning  \theta b block
    hessian(i,n_theta+n_D+j)=(1/obs_theta)*(obs_error-obs_b*log(obs_theta));
    hessian(n_theta+n_D+j,i)=(1/obs_theta)*(obs_error-obs_b*log(obs_theta));


    hessian=2*hessian;
end