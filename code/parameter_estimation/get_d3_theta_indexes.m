%This function identifies the ordering of the parameter vectors
function [d3n_theta_index,d3d_theta_index,equation_index]=get_d3_theta_indexes(data)

    equation_index=data.equation;

    n_indexes=data.education;
    d_indexes=data.education_d;

    temp=zeros(size(n_indexes,1),4);
    tempd=zeros(size(d_indexes,1),4);


    temp(:,1)=n_indexes*10+1;
    temp(:,2)=n_indexes*10+2;
    temp(:,3)=n_indexes*10+3;
    temp(:,4)=n_indexes*10+4;

    tempd(:,1)=d_indexes*10+1;
    tempd(:,2)=d_indexes*10+2;
    tempd(:,3)=d_indexes*10+3;
    tempd(:,4)=d_indexes*10+4;


    theta_code=[11;12;13;14;21;22;23;24;31;32;33;34];


    d3n_theta_index=zeros(size(n_indexes,1),4);
    d3d_theta_index=zeros(size(n_indexes,1),4);

    for col=1:4
        [~,temp_index]=ismember(temp(:,col),theta_code);
        d3n_theta_index(:,col)=temp_index;
        [~,tempd_index]=ismember(tempd(:,col),theta_code);
        d3d_theta_index(:,col)=tempd_index;  
    end

    d3d_theta_index(d3d_theta_index==0)=1;
end
