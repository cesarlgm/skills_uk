function [dummy,param]=expand_matrix(data)
    n_skills=size(data,2);

    for i=1:n_skills
        temp_dat=dummyvar(data(:,i));
        n_val=size(temp_dat,2);
        
        temp_param=zeros(n_val,1);
        temp_param(1,1)=-1;
        temp_param(n_val,1)=1;
        

        if i==1
            dummy=temp_dat;
            param=temp_param;
        else
            dummy=horzcat(dummy,temp_dat);
            param=vertcat(param,temp_param);
        end
    end
end