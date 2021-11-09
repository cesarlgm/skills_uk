function [dta,n_skills]=extract_scale_data(data,education)
    %Extracts information required for scale calibration
    dta=table2array(data(table2array(data(:,education))==1,:));
    dta(:,1:3)=[];

    n_skills=size(dta,2);
end