function restructured_indexes=educ_restructure(index_matrix,education_indexes)
    %This function reshapes the index matrix into a block diagonal matrix
    %splitted by education level

    educ_r=unique(education_indexes);
    n_educ=length(educ_r);

    for i=1:n_educ
        educ_i=educ_r(i);
        row_index=education_indexes==educ_i;
        temp_dat=index_matrix(row_index,:);
        if i==1
            restructured_indexes=temp_dat;
        else
            restructured_indexes=blkdiag(restructured_indexes,temp_dat);
        end
    end
end