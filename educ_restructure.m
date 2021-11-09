function restructured_data=educ_restructure(data,educ_vector)
    %Extracting data from other education groups
    educ_r=unique(educ_vector(educ_vector~=1));
    n_educ=length(educ_r);

    for i=1:n_educ
        educ_i=educ_r(i);
        row_index=educ_vector==educ_i;
        temp_dat=data(row_index,:);
        if i==1
            restructured_data=temp_dat;
        else
            restructured_data=blkdiag(restructured_data,temp_dat);
        end
    end
end