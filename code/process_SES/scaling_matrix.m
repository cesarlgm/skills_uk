function [scale_matrix,restriction_matrix,restriction_b]=scaling_matrix(dummy_matrix,data,n_alphas) %,alpha_A add this if weights are restricted.
    counter=1;
    n_vals=size(dummy_matrix,2);
    n_skills=size(data,2);
    %n_indexes=size(alpha_A,1)/2;

    scale_matrix=zeros(n_vals,n_skills);
    for i=1:n_skills
       %I get the number of categories
       n_cat=length(unique(data(:,i)));
       scale_matrix(counter:counter+n_cat-1,i)=1;
       counter=counter+n_cat;
       
       %Creating restriction matrix
       temp_rest=difference_matrix(n_cat);
       if i==1
           restriction_matrix=temp_rest;
       else
           restriction_matrix=blkdiag(restriction_matrix,temp_rest);
       end
    end
    %Uncomment this line if alphas are constrained to sum to one 
    %restriction_matrix=blkdiag(-1*restriction_matrix,alpha_A);
    
    temp=zeros(size(restriction_matrix,1),n_alphas);
    restriction_matrix=horzcat(-1*restriction_matrix,temp);

    n_restrictions=size(restriction_matrix,1);

    restriction_b=zeros(n_restrictions,1);

    %uncomment this line if weights are restricted to sum to one
    %restriction_b(n_restrictions-n_indexes+1:n_restrictions,1)=ones(n_indexes,1);
end