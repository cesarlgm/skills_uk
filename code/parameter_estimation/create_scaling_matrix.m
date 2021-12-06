function [scale_mult_matrix,scale_restriction_mat]=create_scaling_matrix(dummy_matrix,data) 
    
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
end