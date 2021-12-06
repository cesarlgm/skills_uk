%this creates the matrix imposing the restrictions that the scales are
%monotones.
function dif_mat=difference_matrix(n_cat)
    dif_mat=zeros(n_cat-3,n_cat-2);
    for i=1:n_cat-3
        for j=1:n_cat-2
            if j-i==0
                dif_mat(i,j)=-1;
            elseif j-i==1
                dif_mat(i,j)=1;
            end
        end
    end
end