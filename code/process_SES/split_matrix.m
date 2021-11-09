function div_mat=split_matrix(matrix,column)
    [~,~,index] = unique(matrix(:,column));
    splitted_matrix=accumarray(index,1:size(matrix,1),[],@(r){matrix(r,:)});
    div_mat=splitted_matrix;
end




