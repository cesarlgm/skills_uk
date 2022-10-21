function s_matrix=get_s_matrix_norest(data)
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,["e1s","i_"]);

    s_matrix=table2array(data(:,s_names));
end