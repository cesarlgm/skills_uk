function deviations=create_regression_data(skill_indexes,data,...
    observation_tracker)
    
    deviations=cell(2,1);

    %Step 1: extract the data
    empshares=data{3};
    empshare_tracker=observation_tracker{2};
    skill_tracker=observation_tracker{1};

    n_indexes=size(skill_indexes,2);

    %Step 2: I compute skill index averages
    skill_table=array2table([skill_tracker,skill_indexes]);
    skill_table=grpstats(skill_table,{'Var1','Var3'},'mean');
    skill_table(:,3)=[];
    skill_table=renamevars(skill_table,["Var1","Var3","mean_Var2"],...
        ["occupation","year","job_type"]);

    empshare_table=array2table([empshare_tracker,empshares]);

    empshare_table=renamevars(empshare_table,["Var1","Var2","Var3"],...
        ["occupation","job_type","year"]);


    %Information to compute deviations from averages
    joint_data=join(skill_table,empshare_table);
    
    %table for averages
    job_type_averages=grpstats(joint_data,{'job_type','year'},'mean');
    job_type_averages(:,{'mean_occupation','GroupCount'})=[];

    key_avg=joint_data(:,1:3);
  
    avg_data=join(key_avg,job_type_averages,'LeftKeys',{'job_type','year'}, ...
        'RightKeys',{'job_type','year'});


    dev_avg=table2array(joint_data(:,4:end))-table2array(avg_data(:,4:end));

    regression_data=horzcat(joint_data(:,1:3),array2table(dev_avg));

    deviations{1}=sortrows(regression_data(:,1:3+n_indexes), ...
            {'job_type','occupation','year'});
    deviations{2}=sortrows(regression_data(:,[1:3,3+n_indexes+1]), ...
            {'job_type','occupation','year'});
end