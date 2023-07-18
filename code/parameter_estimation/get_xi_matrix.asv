%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: César Garro-Marín
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function computes the matrix of derivatives of the errors \Xi.

%It returns the \Xi matrix.
function xi_matrix=get_xi_matrix(data, size_vector, vector)
    
    %Preliminary steps
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get variable names
    names=transpose(data.Properties.VariableNames);
    equation=data.equation;

    %Number of observations
    n_obs=size(data,1);

    %Number of jobs
    n_jobs=size_vector(3);

    %Separate \mu into its components
    splitted_vector=assign_parameters(vector,size_vector);
    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};  %Under current version, dlna are the pis
    beta=splitted_vector{3};
    

    %Now I compute derviatives element by each parameter type

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DERIVATIVES WITH RESPECT TO THETA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %I compute this derivative equation by equation
    
    %EQUATIONS 1 and 3
    %For equation 1 I need to compute S_kejt*\pi_ijt. So I need to extract
    %the pis.


    %First, I extract the skills
    skill_names=startsWith(names,["d1s"]);
    skill_temp=table2array(data(:,skill_names));
        
    %Next, I create a matrix with the pi's that will allow me to do
    %element-wise multplication.
    pi_names=startsWith(names,["d2s"]);
    pi_indicators=table2array(data(:,pi_names));

    n_pi=size_vector(2);
    n_theta=size_vector(1);

    %The logic is as follows:
    %pi indicators has the matrix of indicators that multiplied by pi would
    %compute \sum_i pi_i. This is  not what I want. I want a matrix with 12 columns with the
    %correct pi in each column. So,

    %pi_temp is a vector that multiplied by pi returns the pi's of skill i,
    %and zeros everywhere else.

    %Then, pi_matrix*(pi_temp.*d_ln_a) returns a vector with the pi's of
    %skill i.

    %Then multiplied by the skill vector I get the appropriate set of pis
    pi_matrix=zeros(size(data,1),n_theta-2);
    replace_index=zeros(size(data,1),n_theta-2);
    col_counter=1;

    for j=1:3
       for i=1:4
            pi_temp=zeros(n_pi,1);
            pi_temp(i:4:end)=1;

            pi_matrix(:,col_counter)=pi_indicators*(pi_temp.*d_ln_a);

            replace_index(:,col_counter)=pi_indicators*(pi_temp);
            col_counter=col_counter+1;
       end
    end
   
   pi_matrix_final=zeros(size(pi_matrix,1),n_theta-2);
   pi_matrix_final(:,1)=pi_matrix(:,1);
   pi_matrix_final(:,2:n_theta-2)=pi_matrix(:,[2:4,6:8,10:12]);

   replace_index_final=replace_index(:,[2:4,6:8,10:12]);

   %Finally, I compute S_kejt*\pi_ijet. This completes the theta
   %derivatives for equation 1. For equation 3, I still need to add beta. 
   temp_matrix=skill_temp.*pi_matrix_final;


   %This is what I do here: assign the betas to the derivatives. Firt I
   %multiply a job indicator by the beta vector. Then I get the correct
   %beta by summing across columns.
   beta_indicators=table2array(data(:,startsWith(names,["d3s_"])));
   n_beta=size_vector(3);

   for j=1:n_beta 
       beta_matrix(:,j)=beta_indicators(:,j)*beta(j);
   end

   beta_matrix=sum(beta_matrix,2);
   beta_matrix(sum(beta_indicators,2)==0)=1;
   beta_matrix=repmat(beta_matrix,1,size(skill_temp,2));

   %I will use this vector later
   beta_vector=beta_matrix(:,1);

   %I CONCLUDE BY REPLACING ALL THE APPROPRIATE ENTRIES

   %Compute negative of the S_kejt*\pi_ijet
   xi_matrix_1=-skill_temp;

   size(xi_matrix_1)
   size(replace_index)

   %Replace derivatives of the second equation
   xi_matrix_1(replace_index==1)=-temp_matrix(replace_index==1);

   %Add the beta to derivatives of third equation
   xi_matrix_1=xi_matrix_1.*beta_matrix;

   %This completes the derivatives with respect to theta

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO PI
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Again, I go equation by equation

   %Equation 1
   %First I extract the skill and dummy matrices
   skill_matrix=table2array(data(:,startsWith(names,["de1s_"])));
   dummy_matrix=table2array(data(:,startsWith(names,["i_"])));

   %Next, I assign the thetas
   [~,~,e1_educ_index,~,e3_a_index,e3n_educ_index,e3d_educ_index]=get_occ_indexes(data);
   theta_temp=assign_thetas(theta,e1_educ_index);

   %add zeros to fix the size of theta.
   missing_zeros=size(skill_matrix,1)-size(theta_temp,1);
   add_zeros=zeros(missing_zeros,1);
   full_theta=vertcat(theta_temp,add_zeros);

   %create the copied thetas matrix
   theta_matrix=repmat(full_theta,1,size(skill_matrix,2));

   %Step 5: assign thetas for third equation derivatives
   numerator_skills=table2array(data(:,startsWith(names,["de2sn_"])));
   denominator_skills=table2array(data(:,startsWith(names,["de2sd_"])));

   %This line completes the computation of the derivatives for the first
   %equation (dummies are negative ones)
   xi_matrix_2=-theta_matrix.*skill_matrix-dummy_matrix;

   %Equation 3
   %I am assigning some thetas wrongly on purpose. That is corrected once I
   %multiply by the skill matrx.
   [e3nd_theta_indexes,e3dd_theta_indexes,equation_index]=get_d3_theta_indexes(data);

   e3nd_theta_indexes=repmat(e3nd_theta_indexes,1,n_rep_pi);
   e3dd_theta_indexes=repmat(e3dd_theta_indexes,1,n_rep_pi);

   numerator_theta=zeros(n_obs,n_pi);
   denominator_theta=zeros(n_obs,n_pi);

   %Asssign the thetas from numerator and denominator
   for i=1:n_pi 
        numerator_theta(:,i)=assign_thetas(theta,e3nd_theta_indexes(:,i));
        denominator_theta(:,i)=assign_thetas(theta,e3dd_theta_indexes(:,i));
   end

   %Assign the betas
   beta_matrix=repmat(beta_vector,1,n_pi);

   %And compute the derivatives
   e3_pi_derivative=-beta_matrix.*(numerator_skills.*numerator_theta-denominator_skills.*denominator_theta);

   %Finally I replace the third equation derivatives for the appropriate
   %observations.
   xi_matrix_2(equation_index==3,:)=e3_pi_derivative(equation_index==3,:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO BETA
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Equation 3 derivatives
   e3n_skills=table2array(data(:,startsWith(names,["en_"])));
   e3d_skills=table2array(data(:,startsWith(names,["ed_"])));
   e3_occ_index=data.occ_index_3;

    %Now I start with assigning dlna job lines
    full_e3_a_vector=assign_thetas(d_ln_a,e3_a_index);

    %Now I assign thetas to the e3 parameter vectors
    full_e3n_theta=assign_thetas(theta,e3n_educ_index);
    full_e3d_theta=assign_thetas(theta,e3d_educ_index);

    %Compute the theta*pi vectors
    e3_num=full_e3_a_vector.*full_e3n_theta;
    e3_den=full_e3_a_vector.*full_e3d_theta;

   %Next I compute the net sums.
   xi_temp=-(e3n_skills*e3_num-e3d_skills*e3_den);

   xi_matrix_3=zeros(n_obs,n_jobs);

   %Assign the derivatives to the appropriate columns
   for i=1:n_jobs
        xi_matrix_3(e3_occ_index==i,i)=xi_temp(e3_occ_index==i);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO GAMMA
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Step 1: I extract the dummies
   x_indicators=table2array(data(:,startsWith(names,["x_"])));
   xi_matrix_4=-x_indicators;


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %PUTTING EVERYTHING TOGETHER
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   xi_matrix=horzcat(xi_matrix_1, xi_matrix_2,xi_matrix_3, xi_matrix_4);
end