function index_matrix=create_index_matrix(skill_use_matrix,scale_weights,index_composition)
    %This function takes in the skill use matrix and spits the skill
    %index matrix
    
    %First I split the scales by skill index
    splitted_scales=split_scales(scale_weights,index_composition);
    splitted_matrix=split_use_matrix(skill_use_matrix,index_composition);

    n_observations=size(skill_use_matrix,1);
    n_indexes=length(splitted_scales);
    index_matrix=zeros(n_observations,n_indexes);
    for i=1:n_indexes
        index_matrix(:,i)=splitted_matrix{i}*splitted_scales{i};
    end
end