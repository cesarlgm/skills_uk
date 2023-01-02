
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EXTRACTING MATRICES FOR THE GRADIENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sd_matrix,z_indexes,i_indexes,sd2_matrix,num3s,den3s,comparison,num_z,den_z,e3occ_index]=extract_sd_matrix(data)
    names=transpose(data.Properties.VariableNames);

    sd_names=startsWith(names,["e1s"]);
    sd_matrix=table2array(data(:,sd_names));

    i_names=startsWith(names,["i_"]);
    i_indexes=table2array(data(:,i_names));

    sd2_names=startsWith(names,["ts_"]);
    sd2_matrix=table2array(data(:,sd2_names));

    comparison_names=startsWith(names,["x_"]);
    comparison=table2array(data(:,comparison_names));

    num_names=startsWith(names,["ezn_"]);
    num_z=table2array(data(:,num_names));

    den_names=startsWith(names,["ezd_"]);
    den_z=table2array(data(:,den_names));

    e3n_names=startsWith(names,["en_"]);
    num3s=table2array(data(:,e3n_names));

    e3d_names=startsWith(names,["ed_"]);
    den3s=table2array(data(:,e3d_names));

    e1z_names=startsWith(names,["z1s_"]);
    z_indexes=table2array(data(:,e1z_names));

    e3occ_names=startsWith(names,["occ_index_3"]);
    e3occ_index=table2array(data(:,e3occ_names));
end