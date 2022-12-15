function s_matrix=get_s_matrix(data)
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,["e1s","i_","e2_","e3n_","e3d_","x_"]);

    s_matrix=table2array(data(:,s_names));
end