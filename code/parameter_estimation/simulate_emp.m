function [simulated_empshares,skill_averages]=simulate_emp(skill_data,coefs)
    %Compute averages by job
    skill_data(:,4:5)=skill_data(:,4:5)-1;
    
    skill_data(skill_data(:,4)==2,4)=1;
    skill_data(skill_data(:,5)==2,5)=1;

    skill_table=grpstats(array2table(skill_data),{'skill_data1','skill_data2','skill_data3'},'mean');
    
    %Here I erase the extra column that the collapsing generates
    skill_table.GroupCount=[];

    skill_averages=sortrows(table2array(skill_table),[2 1]);

    n_educ=size(coefs,1);
    coefs=transpose(coefs);

    %This part of the code assumes that the data is sorted by education
    for educ=1:n_educ
        index=skill_averages(:,2)==educ;
        temp=skill_averages(index,4:5)*coefs(:,educ);
        if educ==1
            data=temp;
        else 
            data=vertcat(data,temp);
        end
    end
    simulated_empshares=horzcat(skill_averages(:,1:3),data+normrnd(0,1,size(data)));
end