%This function creates all the restrictions required for the alpha matrix
function [D,b,alpha_A]=alpha_restrictions(indexes)
    n_indexes=sum(indexes-1);
    
    %Let alpha be the vector skill weights. D and b are matrices such that
    %D*alpha=b. I will embed these restrictions into the problem. They will
    %not be imposed as a constraint

    %Alpha A imposes the non-negativity of the 1-sum(alpha) weights.

    b=zeros(sum(indexes),1);
    b(cumsum(indexes),1)=1;

    for i=1:length(indexes)
        t_size=indexes(i)-1;
        temp_D=vertcat(eye(t_size),-ones(1,t_size));
        if i==1
            D=temp_D;
        else
            D=blkdiag(D,temp_D);
        end
    end

    alpha_A=transpose(create_alpha_matrix(indexes-1));
    alpha_A=vertcat(-1*alpha_A,alpha_A);
end