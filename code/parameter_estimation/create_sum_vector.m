function skill_sum_res=create_sum_vector(educ_index,sum_vector)
    n_param=length(sum_vector);
    n_obs=size(educ_index,1);

    total_vector=vertcat(1,sum_vector);
    
    for educ=1:(n_param+1)
        educ_length=sum(educ_index==educ);
        temp=ones(educ_length,1)*total_vector(educ,1);
        if educ==1
            skill_sum_res=temp;
        else
            skill_sum_res=vertcat(skill_sum_res,temp);
        end
    end
end