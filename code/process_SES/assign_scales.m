function a_param=assign_parameters(p,rest_index)
    a_param=rest_index;
    a_param(a_param==0,1)=p;
    a_param(a_param==-1,1)=0;
end