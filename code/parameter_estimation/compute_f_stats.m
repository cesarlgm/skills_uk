function [f_stat,p_value]=compute_f_stats(solution,variance_matrix)

    f_stat=zeros(1,3);
    p_value=zeros(1,3);

    %F stat for social coefficients
    R_matrix=zeros(2,size(solution,1));
    b_matrix=zeros(2,1);

    R_matrix(1,2)=1;
    R_matrix(1,10)=-1;

    R_matrix(2,2)=1;
    R_matrix(2,6)=-1;
    
    RV_matrix=zeros(2,size(variance_matrix,1));
   
    RV_matrix(1,1)=1;
    RV_matrix(1,7)=-1;

    RV_matrix(2,1)=1;
    RV_matrix(2,4)=-1;

    r_vector=R_matrix*solution-b_matrix;

    f_stat(1,1)=transpose(r_vector)/(RV_matrix*variance_matrix*transpose(RV_matrix))*r_vector;
    p_value(1,1)=1-chi2cdf(f_stat(1,1),2);


    %F stat for adaptability coefficients
    R_matrix=zeros(2,size(solution,1));
    b_matrix=zeros(2,1);

    R_matrix(1,3)=1;
    R_matrix(1,11)=-1;

    R_matrix(2,3)=1;
    R_matrix(2,7)=-1;
    
    RV_matrix=zeros(2,size(variance_matrix,1));
   
    RV_matrix(1,2)=1;
    RV_matrix(1,8)=-1;

    RV_matrix(2,2)=1;
    RV_matrix(2,5)=-1;

    r_vector=R_matrix*solution-b_matrix;

    f_stat(1,2)=transpose(r_vector)/(RV_matrix*variance_matrix*transpose(RV_matrix))*r_vector;
    p_value(1,2)=1-chi2cdf(f_stat(1,2),2);


    %F stat for abstract coefficients
    R_matrix=zeros(2,size(solution,1));
    b_matrix=zeros(2,1);

    R_matrix(1,4)=1;
    R_matrix(1,12)=-1;

    R_matrix(2,4)=1;
    R_matrix(2,8)=-1;
    
    RV_matrix=zeros(2,size(variance_matrix,1));
   
    RV_matrix(1,3)=1;
    RV_matrix(1,9)=-1;

    RV_matrix(2,3)=1;
    RV_matrix(2,6)=-1;

    r_vector=R_matrix*solution-b_matrix;

    f_stat(1,3)=transpose(r_vector)/(RV_matrix*variance_matrix*transpose(RV_matrix))*r_vector;
    p_value(1,3)=1-chi2cdf(f_stat(1,3),2);
end