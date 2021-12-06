function splitted_vector=split_scales(scale_weights,index_composition)
    splitted_vector=mat2cell(scale_weights,index_composition,1);
end