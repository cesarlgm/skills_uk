function splitted_matrix=split_use_matrix(skill_use_matrix,index_composition)
    splitted_matrix=mat2cell(skill_use_matrix,size(skill_use_matrix,1), ...
        index_composition);
end