%this function computes the scale iteration step

function [new_scales,MSE]=get_scales(new_theta,old_scales, data, ...
        computation_information,minimization_input,job_type_index,alpha_restrictions)

    %annonymizing scale error funtion
    fun=@(loop_over)get_scale_error(loop_over, new_theta, ...
        data,computation_information,job_type_index,alpha_restrictions);
    

    %STEP 5: solve the problem
    options = optimset('TolX',1e-10,'MaxFunEvals',10000e3,'PlotFcn','optimplotfval');

    %minimize scale errors
    [new_scales,MSE]=fmincon(fun,old_scales,minimization_input{1}, ...
        minimization_input{2},[],[],minimization_input{3}, ...
        minimization_input{4},[],options);
end