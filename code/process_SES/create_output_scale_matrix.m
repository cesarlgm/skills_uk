function scale_matrix=create_output_scale_matrix(solution,skill_data,n_skills,varnames)
    
    n_scales=count_n_scales(skill_data);

    scale_matrix=zeros(max(n_scales),n_skills);

    counter=1;
    for i=1:n_skills
        index=n_scales(i);
        %Filling up scales
        n_param=index-2;
        
        scale_matrix(2:index-1,i)=solution(counter:counter+n_param-1);
        
        %Filling up the ones
        scale_matrix(index,i)=1;

        if length(scale_matrix(:,i))>index
            scale_matrix(index+1:index+1,i)=NaN;
        end
        counter=counter+n_param;
    end
    row_names={'1','2','3','4','5'}
    scale_matrix=array2table(scale_matrix,'VariableNames',varnames,'RowNames',row_names)
end
