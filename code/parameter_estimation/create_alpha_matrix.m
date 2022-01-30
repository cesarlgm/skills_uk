function alpha_matrix=create_alpha_matrix(skill_indexes)
    n_skills=sum(skill_indexes);
    n_indexes=length(skill_indexes);

    alpha_matrix=zeros(n_skills,n_indexes);

    r_indexes=[0,cumsum(skill_indexes)];

    for i=1:n_indexes
        i_start=r_indexes(i)+1;
        i_end=r_indexes(i+1);
        i_length=skill_indexes(i);
        alpha_matrix(i_start:i_end,i)=ones(i_length,1);
    end
end