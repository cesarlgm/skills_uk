%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: César Garro-Marín
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function computes the matrix of derivatives of the errors \Xi.

function xi_matrix=get_xi_matrix(data, size_vector, vector)
    %Preliminary steps
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get variable names
    names=transpose(data.Properties.VariableNames);

    %Separate the vector into its components
    splitted_vector=assign_parameters(vector,size_vector);
    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};     %Under the current version, d_ln_a here stands for pi.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DERIVATIVES WITH RESPECT TO THETA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %I compute this derivative equation by equation


    %EQUATION 1
    %For equation 1 I need to compute S_kejt*\pi_ijt. So I need to extract
    %the pis.


    %First, I extract the skills
    %Note: the pi's of some education leves are badly assigned, but this is 
    %not an issue, as it is corrected in the next step.
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


   %Finally, I compute S_kejt*\pi_ijet. This completes the theta
   %derivatives for equation 1. For equation 3, I still need to add beta. 
   temp_matrix=skill_temp.*pi_matrix;

   %Replace the appropriate derivatives in the data matrix
   xi_matrix_1=-skill_temp;
   xi_matrix_1(replace_index==1)=-temp_matrix(replace_index==1);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO PI
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Again, I go equation by equation
   
   %Equation 1
   %First I extract the skill and dummy matrices
   skill_matrix=table2array(data(:,startsWith(names,["de1s_"])));
   dummy_matrix=table2array(data(:,startsWith(names,["i_"])));
   
   %Next, I assign the thetas
   [~,~,e1_educ_index]=get_occ_indexes(data);
   theta_temp=assign_thetas(theta,e1_educ_index);

   %add zeros to fix the size of theta.
   missing_zeros=size(skill_matrix,1)-size(theta_temp,1);
   add_zeros=zeros(missing_zeros,1);
   full_theta=vertcat(theta_temp,add_zeros);

   %create the copied thetas matrix
   theta_matrix=repmat(full_theta,1,size(skill_matrix,2));

   xi_matrix_2=-theta_matrix.*skill_matrix-dummy_matrix;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %PUTTING EVERYTHING TOGETHER
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   xi_matrix=horzcat(xi_matrix_1,xi_matrix_2);
end