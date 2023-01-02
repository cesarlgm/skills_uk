%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create_linear_vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes a vector of GMM parameters and assigns them to the proper places so that the GMM error is linear in these parameters.
% Functions it requires:
% -	assign_parameters
% -	assign_sigmas
% -	assign_thetas

%Latest modifications:
%Dropped all references to equation 3 and 2 from the linear parameter vector
%Modified form of equation 1.
function result=create_linear_vector(parameter_vector,size_vector,...
    e1_d_ln_a_index,e1_educ_index,e3_job_index,e3_a_index,e3n_educ_index,e3d_educ_index)
    
    %Split parameter vector into parameter type
    splitted_vector=assign_parameters(parameter_vector,size_vector);

    %Extracting dlnA vector
    %Abstract pi's are restricted to be zero.
    d_ln_a=splitted_vector{2};

    %Creates the skill by job full dlnA vector 
    %What happens in this step?
    %I have a vector of d_ln_a that is size JT. However the parameter
    %vector that I want is of size "roughly" 3JT. So I have to assign dlna
    %to the full size vector in the appropriate order.
    %FUTURE ME: bear in mind that the appropriate order is education, job,
    %skill and year.

    %I get these indexes in the function get_occ_indexes
    %e_1_full_d_ln_a=d_ln_a;
    e_1_full_d_ln_a=assign_thetas(d_ln_a,e1_d_ln_a_index);


    %Now I get the theta vector
    theta=splitted_vector{1};

    %I reorder the parameters in the "right order"
    %Parameters equation 1
    %Under the current form, these are just the pis
    
    %I assign thetas accorduing to the appropriate education level
    %I have defined beta as sigma-1/sigma
    full_theta=assign_thetas(theta,e1_educ_index);
    

    %Now I get the paramaters of the third equation
    
    %theta parameters
    beta_inv=splitted_vector{3};
    %Pairwise comparison 
    comparison=splitted_vector{4};


    %I assign the betas to the full error vector
    full_beta_inv=assign_sigmas(beta_inv,e3_job_index);


    %Parameters equation 1
    theta_pi=e_1_full_d_ln_a.*full_theta;
    eqn1part_2=d_ln_a;

    %Now I start with assigning dlna job lines
    full_e3_a_vector=assign_thetas(d_ln_a,e3_a_index);

    %Now I assign thetas to the e3 parameter vectors
    full_e3n_theta=assign_thetas(theta,e3n_educ_index);
    full_e3d_theta=assign_thetas(theta,e3d_educ_index);


    e3_num=full_e3_a_vector.*full_e3n_theta.*full_beta_inv;
    e3_den=-1*full_e3_a_vector.*full_e3d_theta.*full_beta_inv;

    result=vertcat(theta_pi,eqn1part_2,theta,e3_num,e3_den,comparison);
end