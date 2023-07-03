function xi_matrix=get_xi_matrix(data, size_vector, vector)
    names=transpose(data.Properties.VariableNames);

    %Step 0: I separate the vector into its components
    splitted_vector=assign_parameters(vector,size_vector);

    %Extracting dlnA vector
    %Under the current version, d_ln_a here stands for pi.
    theta=splitted_vector{1};
    d_ln_a=splitted_vector{2};
    
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


   %Replace the appropriate derivatives in the data matrix
   xi_matrix_1=skill_temp;
   xi_matrix_1(replace_index==1)=-temp_matrix(replace_index==1);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %COMPUTE DERIVATIVES WITH RESPECT TO PI
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   xi_matrix=xi_matrix_1;
end