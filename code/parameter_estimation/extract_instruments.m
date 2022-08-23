function result=extract_instruments(data)
    %I start by extracting equation 1 instruments
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,"z1s_1_","z1s_2_","i_","ts_");

    result=table2array(data(:,s_names));
end