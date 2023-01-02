%This computes the derivatives of the second error equation
function de_eq2=get_de_eq2(skill_matrix,n_parameters)

    %Number of columns of derivatives with respect to other parameters
    n_missing_cols=n_parameters-size(skill_matrix,2);

    %Create the matrix of derivatives
    other_dev=zeros(size(skill_matrix,1),n_missing_cols);

    %Final matrix of derivatives
    de_eq2=horzcat(skill_matrix,other_dev);
end