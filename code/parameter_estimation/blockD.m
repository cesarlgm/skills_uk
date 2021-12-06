function B =blockD(A,column)
n=size(A,1);
B=A{1};
B(:,column)=[];
    for i = 2:n
       temp_mat=A{i};
       temp_mat(:,column)=[];
       B=blkdiag(B,temp_mat);
    end
end