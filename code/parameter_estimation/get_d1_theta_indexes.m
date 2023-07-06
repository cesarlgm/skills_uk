%This function identifies the ordering of the parameter vectors
function d1_theta_index=get_d1_theta_indexes(data)

    names=transpose(data.Properties.VariableNames);

    eqn_1_indexes=names(startsWith(names,"e1s"));
    
    %Indexes for vector 1
    splitted_name=split(eqn_1_indexes,"_");
    
    e1_education_index=str2double(splitted_name(:,3));

    temp=zeros(size(e1_education_index,1),4);

    temp(:,1)=e1_education_index*10+1;
    temp(:,2)=e1_education_index*10+2;
    temp(:,3)=e1_education_index*10+3;
    temp(:,4)=e1_education_index*10+4;

    theta_code=[11;12;13;14;21;22;23;24;31;32;33;34];


    d1_theta_index=zeros(size(e1_education_index,1),4);

    for col=1:4
        [~,temp_index]=ismember(temp(:,col),theta_code);
        d1_theta_index(:,col)=temp_index;
    end
end
