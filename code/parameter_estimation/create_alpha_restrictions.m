%This function creates all the restrictions required for the alpha matrix
function alpha_restrictions=create_alpha_restrictions(index_composition)
    n_indexes=length(index_composition);
    %Let alpha be the vector skill weights. D and b are matrices such that
    %D*alpha=b. I will embed these restrictions into the problem. They will
    %not be imposed as a constraint

    %Alpha A imposes the non-negativity of the 1-sum(alpha) weights and the
    %constraint that they have to be less than one.
    %the constraint I want to pass is alpha_A*alpha<alpha_b

    b=zeros(sum(index_composition),1);
    b(cumsum(index_composition),1)=1;

    for i=1:n_indexes
        t_size=index_composition(i)-1;
        temp_D=vertcat(eye(t_size),-ones(1,t_size));
        if i==1
            D=temp_D;
        else
            D=blkdiag(D,temp_D);
        end
    end

    alpha_A=transpose(create_alpha_matrix(index_composition-1));
    
    %The first part constrains the alphas to be positive
    %The second part constrains them to be less than one.
    alpha_A=vertcat(-1*alpha_A,alpha_A);

    n_indexes=size(index_composition,2);
    alpha_b=vertcat(zeros(n_indexes,1),ones(n_indexes,1));

    %Saving the restrictions into the output
    alpha_restrictions=cell(4,1);
    alpha_restrictions{1,1}=D;
    alpha_restrictions{2,1}=alpha_A;
    alpha_restrictions{3,1}=b;
    alpha_restrictions{4,1}=alpha_b;
end