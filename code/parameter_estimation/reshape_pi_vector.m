function sd_first_part=reshape_pi_vector(pi_vector,e1_educ_index,sd_matrix)
    pi_size=size(pi_vector,1);
    r_pi_vector=ones(pi_size,12);

    for j=1:12 
        r_pi_vector(e1_educ_index~=j,j)=0;
        r_pi_vector(:,j)=r_pi_vector(:,j).*pi_vector;
    end

    %Derivative of the errors.
    sd_first_part=-1*(sd_matrix*r_pi_vector);
end