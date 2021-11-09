function rsm=reshape_matrix(matrix, column)
    splitted_matrix=split_matrix(matrix,column);
    rsm=blockD(splitted_matrix,column);
end