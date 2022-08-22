function result=extract_instruments(data)
    %I start by extracting equation 1 instruments
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,"e1s","i_","ts_");

    result=table2array(data(:,s_names));
end