function n_weights=create_n_weights(index_composition,restricted)
    if restricted==0
        n_weights=sum(index_composition);
    else
        n_weights=sum(index_composition)-length(index_composition);
    end
end