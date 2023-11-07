%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: César Garro-Marín
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function computes the matrix of derivatives of the errors \Xi, when
%manual costs are not restricted

function xi_matrix=get_xi_matrix(data, size_vector, vector,n_skills)
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

    
    %First, I extract the skills
    skill_names=startsWith(names,["d1s"]);
    skill_temp=table2array(data(:,skill_names));
        
    %Next, I create a matrix with the pi's that will allow me to do
    %element-wise multplication.
    pi_names=startsWith(names,["d2s"]);
    pi_indicators=table2array(data(:,pi_names));

    n_pi=size_vector(2);
    n_theta=size_vector(1);


    %In this section of the codeI generate a matrix that has the appropiate
    %pi's in each column to compute the derivatives with respect to theta
    %for equations 1 and 3

    %I need a Nx12 matrix.

    %These are the elements
    %pi_matrix: result matrix I want.
    %pi_indicators: indicators that multiplied by dlnA gives the sums of
    %the dlnA
    %pi_temp: matrix of indicators that multplied by dlnA gives only the
    %pi's of a given skill.

    pi_matrix=zeros(size(data,1),n_theta);
    pi_matrix_final=zeros(size(data,1),n_theta);
    replace_index=zeros(size(data,1),n_theta);
    col_counter=1;

    %This is a Nx12 matrix. 
    for j=1:3
       for i=1:4
            pi_temp=zeros(n_pi,1);
            pi_temp(i:4:end)=1;

            pi_matrix(:,col_counter)=pi_indicators*(pi_temp.*d_ln_a);

            replace_index(:,col_counter)=pi_indicators*(pi_temp);
            col_counter=col_counter+1;
       end
    end
   
   
   %Here is where I fix the sizing issue
   pi_matrix_final=zeros(size(pi_matrix,1),n_theta);
   %The first column corresponds to manual, while the rest are the non-manual columns

  
   pi_matrix_final(:,[2:4,6:8,10:12])=pi_matrix(:,[2:4,6:8,10:12]);
   replace_index_final=replace_index;
   
   

   %Finally, I compute S_kejt*\pi_ijet. This completes the theta
   temp_matrix=skill_temp.*pi_matrix_final;
   


   %Replace the appropriate derivatives in the data matrix
   xi_matrix_1=-skill_temp;
   xi_matrix_1(replace_index_final==1)=-temp_matrix(replace_index_final==1);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO PI
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Again, I go equation by equation

   %Equation 1
   %First I extract the skill and dummy matrices
   skill_matrix=table2array(data(:,startsWith(names,["de1s_"])));
   dummy_matrix=table2array(data(:,startsWith(names,["i_"])));

   %Next, I assign the thetas
   [~,~,e1_educ_index]=get_occ_indexes(data,n_skills);
   theta_temp=assign_thetas(theta,e1_educ_index);

   %add zeros to fix the size of theta.
   missing_zeros=size(skill_matrix,1)-size(theta_temp,1);
   add_zeros=zeros(missing_zeros,1);
   full_theta=vertcat(theta_temp,add_zeros);

   %create the copied thetas matrix
   theta_matrix=repmat(full_theta,1,size(skill_matrix,2));

   xi_matrix_2=-theta_matrix.*skill_matrix-dummy_matrix;

   %Drop columns columns corresponding to derivatives with respect to pi
   %manual
   xi_matrix_2(:,1:4:end)=[];


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %PUTTING EVERYTHING TOGETHER
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   xi_matrix=horzcat(xi_matrix_1,xi_matrix_2);
end