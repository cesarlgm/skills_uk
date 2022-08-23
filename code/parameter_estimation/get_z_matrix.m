function z_matrix=get_z_matrix(data)
    %Instruments for first equation are job by year dummies
    %Instruments for second equation are the skills
    %Instruments for third equation are 
    names=transpose(data.Properties.VariableNames);

    z_names=startsWith(names,["z1s_","i_","ts_"]);
    z_matrix=table2array(data(:,z_names));
end