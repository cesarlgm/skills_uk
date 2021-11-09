function n_scales=extract_n_scales(data,n_skills)

    n_scales=zeros(n_skills,1);
    for i=1:n_skills 
        n_scales(i,1)=length(unique(table2array(data(:,i))));
    end
end