function s_matrix=get_s_matrix(data)
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,["e1s_","i_","e2_","en_","ed_","x_"]);

    s_matrix=table2array(data(:,s_names));
end