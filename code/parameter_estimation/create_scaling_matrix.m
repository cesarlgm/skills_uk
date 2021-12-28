function [scale_mult_matrix,minimization_inputs]=create_scaling_matrix(dummy_matrix,data) 
    
    %This function performs two different tasks:
    % 1. Creates the matrix of ones to multiply to the vector of alphas.
    % 2. Creates the matrix of non-negativity restrictions,
    counter=1;
    n_vals=size(dummy_matrix,2);
    n_skills=size(data,2);


    scale_mult_matrix=zeros(n_vals,n_skills);
    for i=1:n_skills
       %I get the number of categories
       n_cat=length(unique(data(:,i)));
       scale_mult_matrix(counter:counter+n_cat-1,i)=1;
       counter=counter+n_cat;
       
       %Creating restriction matrix
       temp_rest=difference_matrix(n_cat);
       if i==1
           scale_restriction_mat=temp_rest;
       else
           scale_restriction_mat=blkdiag(scale_restriction_mat,temp_rest);
       end
    end

    scale_restriction_mat=-1*scale_restriction_mat;
    n_scales=size(scale_restriction_mat,2);

    %I resize the matrix to add empty restrictions for the weights
    restriction_size=size(scale_restriction_mat,1);
    zero_mat=zeros(restriction_size,n_skills);
    missing_columns=size(zero_mat,2);

    scale_restriction_mat=horzcat(scale_restriction_mat,zero_mat);


    %Creating b vector for the minimiztation
    restriction_b=zeros(restriction_size,1);


    %Creating upper and lower bounds
    upper_bounds=vertcat(ones(n_scales,1),Inf*ones(missing_columns,1));
    lower_bounds=vertcat(ones(n_scales+missing_columns,1));


    minimization_inputs=cell(4,1);
    minimization_inputs{1}=scale_restriction_mat;
    minimization_inputs{2}=restriction_b;
    minimization_inputs{4}=upper_bounds;
    minimization_inputs{3}=lower_bounds;
end
