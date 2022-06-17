function s_matrix=get_s_matrix(data)
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,["a_","i_","ts_","en_","ed_","x_"]);

    s_matrix=table2array(data(:,s_names));
end