function deviations=create_regression_data(skill_indexes,data,...
    observation_tracker)
    
    deviations=cell(2,1);

    %Step 1: extract the data
    empshares=data{3};
    empshare_tracker=observation_tracker{2};
    skill_tracker=observation_tracker{1};

    n_indexes=size(skill_indexes,2);

    %Step 2: arrange the data into a suitable format
    skill_table=array2table([skill_tracker,skill_indexes]);
    skill_table=grpstats(skill_table,{'Var1','Var2','Var3'},'mean');
    
    skill_table.GroupCount=[];
    skill_table=renamevars(skill_table,["Var1",'Var2',"Var3"],...
        ["occupation","job_type","year"]);

    empshare_table=array2table([empshare_tracker,empshares]);
    empshare_table=renamevars(empshare_table,["Var1","Var2","Var3"],...
        ["occupation","job_type","year"]);

    %This line outputs the skill index data. No averages needed anymore
    deviations{1}=sortrows(skill_table, ...
            {'job_type' 'occupation' 'year'});
    %This line outputs the empshare data. No averages needed.
    deviations{2}=sortrows(empshare_table, ...
            {'job_type' 'occupation' 'year'});
end