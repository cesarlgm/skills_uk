function [empshare_data, empshare_tracker]=extract_share_data(share_path)
     
    data=readtable(share_path);
    
    empshare_data=table2array(data(:,'d_l_educ_empshare'));

    education_index=table2array(data(:,'education'));
    
    occ_index=table2array(data(:,'occupation'));

    year_index=table2array(data(:,'year'));

    empshare_tracker=[occ_index,education_index,year_index];  
end