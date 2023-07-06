function xi_matrix=get_xi_matrix(data, size_vector, vector)
    names=transpose(data.Properties.VariableNames);
    n_obs=size(data,1);
    n_jobs=size_vector(3);

    %Step 0: I separate the vector into its components
    splitted_vector=assign_parameters(vector,size_vector);

    %Extracting dlnA vector
    %Under the current version, d_ln_a here stands for pi.
    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};
    beta=splitted_vector{3};
    n_rep_pi=size_vector(2)/4;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %COMPUTING DERIVATIVES WITH RESPECT TO  THETA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 1: assign the pi's to each of the observations
    %To do so, I first extract the matrix of indicators by job
    pi_names=startsWith(names,["d2s"]);
    pi_indicators=table2array(data(:,pi_names));

   n_pi=size_vector(2);
   n_theta=size_vector(1);

   pi_matrix=zeros(size(data,1),n_theta);
   replace_index=zeros(size(data,1),n_theta);
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

   %Note: the pi's of some education leves are badly assigned, but this is 
   %not an issue, as it is corrected in the next step.
   skill_names=startsWith(names,["d1s"]);
   skill_temp=table2array(data(:,skill_names));
   
   %Step 2: compute derivatives with respect to theta
   %Multiply skill indexes by the pi's to compute derivatives in first
   %equation
   temp_matrix=skill_temp.*pi_matrix;


   %Step 3:
   %Assign the betas to the derivatives
   beta_indicators=table2array(data(:,startsWith(names,["d3s_"])));
   n_beta=size_vector(3);

   for j=1:n_beta 
       beta_matrix(:,j)=beta_indicators(:,j)*beta(j);
   end

   beta_matrix=sum(beta_matrix,2);
   beta_matrix(sum(beta_indicators,2)==0)=1;
   beta_matrix=repmat(beta_matrix,1,size(skill_temp,2));

   beta_vector=beta_matrix(:,1);


   %Replace the appropriate derivatives in the data matrix
   xi_matrix_1=-skill_temp;

   %Replace derivatives of second equation
   xi_matrix_1(replace_index==1)=-temp_matrix(replace_index==1);

   %Add the beta to derivatives of third equation
   xi_matrix_1=xi_matrix_1.*beta_matrix;


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO PI
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Step 1: get the skills and the indicators
   skill_matrix=table2array(data(:,startsWith(names,["de1s_"])));
   dummy_matrix=table2array(data(:,startsWith(names,["i_"])));
   
   %the thetas are assigned wrongly
   %Step 2: assign the thetas
   [~,~,e1_educ_index,~,e3_a_index,e3n_educ_index,e3d_educ_index]=get_occ_indexes(data);
   theta_temp=assign_thetas(theta,e1_educ_index);

   %Step 3: fix size of the theta vector
   missing_zeros=size(skill_matrix,1)-size(theta_temp,1);
   add_zeros=zeros(missing_zeros,1);
   full_theta=vertcat(theta_temp,add_zeros);

   %Step 4: create the copied thetas matrix
   theta_matrix=repmat(full_theta,1,size(skill_matrix,2));

   %Step 5: assign thetas for third equation derivatives
   numerator_skills=table2array(data(:,startsWith(names,["de2sn_"])));
   denominator_skills=table2array(data(:,startsWith(names,["de2sd_"])));


   %Step 5.1: create theta indexes for the third equation
   [e3nd_theta_indexes,e3dd_theta_indexes,equation_index]=get_d3_theta_indexes(data);

   e3nd_theta_indexes=repmat(e3nd_theta_indexes,1,n_rep_pi);
   size(e3nd_theta_indexes)
   e3dd_theta_indexes=repmat(e3dd_theta_indexes,1,n_rep_pi);

   numerator_theta=zeros(n_obs,n_pi);
   denominator_theta=zeros(n_obs,n_pi);
   %Something is wrong with these thetas
   for i=1:n_pi 
        numerator_theta(:,i)=assign_thetas(theta,e3nd_theta_indexes(:,i));
        denominator_theta(:,i)=assign_thetas(theta,e3dd_theta_indexes(:,i));
   end

   beta_matrix=repmat(beta_vector,1,n_pi);

   e3_pi_derivative=-beta_matrix.*(numerator_skills.*numerator_theta-denominator_skills.*denominator_theta);


   %Creating the derivative pi matrix
   xi_matrix_2=-theta_matrix.*skill_matrix-dummy_matrix;
   xi_matrix_2(equation_index==3,:)=e3_pi_derivative(equation_index==3,:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO BETA
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   e3n_skills=table2array(data(:,startsWith(names,["en_"])));
   e3d_skills=table2array(data(:,startsWith(names,["ed_"])));
   e3_occ_index=data.occ_index_3;

    %Now I start with assigning dlna job lines
    full_e3_a_vector=assign_thetas(d_ln_a,e3_a_index);
    
    %Now I assign thetas to the e3 parameter vectors
    full_e3n_theta=assign_thetas(theta,e3n_educ_index);
    full_e3d_theta=assign_thetas(theta,e3d_educ_index);
    
    
    e3_num=full_e3_a_vector.*full_e3n_theta;
    e3_den=full_e3_a_vector.*full_e3d_theta;

   xi_temp=-(e3n_skills*e3_num-e3d_skills*e3_den);

   xi_matrix_3=zeros(n_obs,n_jobs);
   for i=1:n_jobs
        xi_matrix_3(e3_occ_index==i,i)=xi_temp(e3_occ_index==i);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO GAMMA
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Step 1: I extract the dummies
   x_indicators=table2array(data(:,startsWith(names,["x_"])));
    
   xi_matrix_4=-x_indicators;

   xi_matrix=horzcat(xi_matrix_1, xi_matrix_2,xi_matrix_3, xi_matrix_4);
end