%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get initial beta_inv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q_error=get_beta_inv_init(beta,theta,pi,e3n,e3d, ...
    e3_a_index,e3n_educ_index,e3d_educ_index,e3job_obs,y_matrix,comparison,num_z,den_z)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 1> CREATE THE RIGHT HAND SIDE OF THE EQUATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Assign the vector of pi's to the equation
    full_e3_pi_vector=assign_thetas(pi,e3_a_index);

    %Next I assign the vector of thetas
    full_e3n_theta=assign_thetas(theta,e3n_educ_index);
    full_e3d_theta=assign_thetas(theta,e3d_educ_index);

    %Next I compute the numerator and denominators parts of the equation
    numerator=  e3n*(full_e3n_theta.*full_e3_pi_vector);
    denominator=e3d*(full_e3d_theta.*full_e3_pi_vector);

    %Now I compute the left hand side of the equation
    x_part_1_temp=numerator-denominator;

    %Now I create as many columns as jobs there are
    n_jobs=max(e3job_obs);

    x_part_1=zeros(size(e3job_obs,1),n_jobs);
    for i=1:n_jobs
        x_part_1(e3job_obs==i,i)=x_part_1_temp(e3job_obs==i,1);
    end

    x_matrix=horzcat(x_part_1,comparison);

    X=x_matrix(e3job_obs>0,:);
    Y=y_matrix(e3job_obs>0,:);

    e3indexes=e3job_obs~=0;

    n_obs=sum(e3indexes);

    numz=num_z(e3indexes,:);
    denz=den_z(e3indexes,:);
    comp_z=comparison(e3indexes,:);
    

    e3z_matrix=horzcat(numz,denz,comp_z);

    error=Y-X*beta;

    q_error=(1/n_obs)*(transpose(error)*e3z_matrix/(transpose(e3z_matrix)*e3z_matrix)*transpose(e3z_matrix)*error);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end