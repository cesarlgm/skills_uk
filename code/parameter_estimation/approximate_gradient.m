function gradient=approximate_gradient(function_to_dif, point, delta)
    n_parameters=size(point,1)-4;

    gradient=zeros(n_parameters,1);
    
    init_eval=function_to_dif(point);

    for i=1:n_parameters
        end_point=point;
        if i<=3
            end_point(i+1)=end_point(i+1)+delta;
        elseif i<=6
            end_point(i+2)=end_point(i+2)+delta;
        elseif i<=1116
            end_point(i+3)=end_point(i+3)+delta;
        elseif i>1116
            end_point(i+4)=end_point(i+4)+delta;
        end
        gradient(i,1)=(function_to_dif(end_point)-init_eval)/delta;
    end
end