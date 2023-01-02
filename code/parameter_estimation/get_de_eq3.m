
function de_eq3=get_de_eq3(parameter,num3s,den3s,comparison,e3_a_index,e3_occ_index,e3n_educ_index,e3d_educ_index,size_vector,e3job_obs)

    n_obs=size(num3s,1);
    n_j=max(e3job_obs);
    n_pi=max(e3_a_index);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %First I split the parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    splitted_vector=assign_parameters(parameter,size_vector);
    theta=splitted_vector{1};
    pi=splitted_vector{2};
    chi=splitted_vector{3};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %I compute the derivatives with respect to theta
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    full_e3_pi_vector=assign_thetas(pi,e3_a_index);
    full_e3_chi_vector=assign_thetas(chi,e3_occ_index);

    chi_pi=full_e3_pi_vector.*full_e3_chi_vector;

    %I fill up the derivatives with respect to theta
    for i=1:12 
        indexes_n=e3n_educ_index==i;
        indexes_n=indexes_n.*chi_pi;

        indexes_d=e3d_educ_index==i;
        indexes_d=indexes_d.*chi_pi;

        de_eq3_1(:,i)=-num3s*indexes_n+den3s*indexes_d;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Derivatives with respect to pi's
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    full_e3n_theta=assign_thetas(theta,e3n_educ_index);
    full_e3d_theta=assign_thetas(theta,e3d_educ_index);

    %First I compute the product between chi and theta
    chi_theta_n=full_e3n_theta.*full_e3_chi_vector;
    chi_theta_d=full_e3d_theta.*full_e3_chi_vector;
    
    de_eq3_3=zeros(n_obs,n_pi);
    for k=1:n_pi
        pi_index=e3_a_index==k;
        pi_product_n=chi_theta_n.*pi_index;
        pi_product_d=chi_theta_d.*pi_index;
        de_eq3_3(:,k)=-(num3s*pi_product_n-den3s*pi_product_d);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Derivatives with respect to chi's
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %First I expand the theta parameters


    full_e3_api_vector=assign_thetas(pi,e3_a_index);
    
    pi_theta_num=full_e3n_theta.*full_e3_api_vector;
    pi_theta_den=full_e3d_theta.*full_e3_api_vector;
    
    de_eq3_temp=-1*(num3s*pi_theta_num-den3s*pi_theta_den);
    
    de_eq3_2=zeros(n_obs,n_j);
    for j=1:n_j
        de_eq3_2(e3job_obs==j,j)=de_eq3_temp(e3job_obs==j,1);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Derivatives with respect to comparison dummies
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    d_comp=-comparison;

    de_eq3=horzcat(de_eq3_1,de_eq3_2,de_eq3_3,d_comp);
end