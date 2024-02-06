function hessian=approximate_hessian(gradient, point, delta)
    n_parameters=size(point,1)-4;

    hessian=zeros(n_parameters,n_parameters);
    
    init_eval=gradient(point);

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
        hessian(i,:)=(gradient(end_point)-init_eval)/delta;
    end
end