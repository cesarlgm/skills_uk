function  d_matrix=create_d_matrix(z_matrix,sd_matrix,i_indexes,n_parameters,de_eq_1,de_eq_2,de_eq_3)
    n_inst=size(z_matrix,2);

    d_matrix=zeros(n_inst,n_parameters);
    n_eq_1_inst=size(sd_matrix,2)+size(i_indexes,2);
    n_eq_2_inst=12;
    n_eq_3_inst=size(z_matrix,2)-n_eq_2_inst-n_eq_1_inst;

    for i=1:n_eq_1_inst
        temp=transpose(z_matrix(:,i))*de_eq_1;
        d_matrix(i,:)=temp;
    end

    %Add multiplication of equation 2 parameters
    row_counter=n_eq_1_inst;
    for i=1:n_eq_2_inst
        temp=transpose(z_matrix(:,i+row_counter))*de_eq_2;
        d_matrix(i+row_counter,:)=temp;
    end

    row_counter=n_eq_1_inst+n_eq_2_inst;
    %Add multiplication of equation 3 parameters
    for i=1:n_eq_3_inst
        temp=transpose(z_matrix(:,i+row_counter))*de_eq_3;
        d_matrix(i+row_counter,:)=temp;
    end
end