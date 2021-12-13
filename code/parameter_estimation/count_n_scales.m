function n_scales=count_n_scales(skill_data)
    n_columns=size(skill_data,2);

    for i=1:n_columns
        temp=length(unique(skill_data(:,i)));

        if i==1
            n_scales=temp;
       
        else
            n_scales=vertcat(n_scales,temp);
        end
    end
end
