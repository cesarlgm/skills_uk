%This function takes the matrix of skill indexes and spits out average
%skill use by job and education group.
function [avg_use,job_grp]=average_skill_use(skill_indexes,occ_index,job_type_index)
    [avg_use,grp]=grpstats(skill_indexes,{job_type_index,occ_index},{'mean','gname'});
    job_grp=str2num(vertcat(grp{:,1}));
end