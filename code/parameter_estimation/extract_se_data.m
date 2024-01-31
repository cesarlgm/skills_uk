function gradient_matrix=extract_se_data(data)
    
    names=transpose(data.Properties.VariableNames);

    s_names=startsWith(names,["g"]);
        
    gradient_matrix=table2array(data(:,s_names));

end