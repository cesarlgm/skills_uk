
%This function computes the derivatives of the errors of the first equation
function sd_matrix=get_de_eq1(sd_matrix,theta, ...
    e1_educ_index,e1_d_ln_a_index,i_indexes,n_parameters,e1_full_pi)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GETTING FIRST PART OF SD MATRIX
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sd_first_part=reshape_pi_vector(e1_full_pi,e1_educ_index,sd_matrix);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GETTING SECOND PART OF SD MATRIX
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    full_pi_size=size(e1_d_ln_a_index,1);
    n_pi=max(e1_d_ln_a_index);

    n_zeros=n_parameters-n_pi-size(theta,1);
    
    index_matrix=zeros(full_pi_size,n_pi);

    full_theta=assign_thetas(theta,e1_educ_index);

    for i=1:n_pi
        index_matrix(e1_d_ln_a_index==i,i)=1;
        index_matrix(:,i)=index_matrix(:,i).*full_theta;
    end
    
    zero_matrix=zeros(size(sd_matrix,1),n_zeros);
    sd_second_part=horzcat(-(sd_matrix*index_matrix)-i_indexes,zero_matrix);

    sd_matrix=horzcat(sd_first_part,sd_second_part);
end