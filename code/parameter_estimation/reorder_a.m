function reordered_a=reorder_a(dln_a)
    full_size=size(dln_a,1);
    dln_a_s1_i=mod(transpose(1:full_size),3)==1;
    dln_a_s2_i=mod(transpose(1:full_size),3)==2;
    dln_a_s3_i=mod(transpose(1:full_size),3)==0;

    reordered_a_1=dln_a(dln_a_s1_i);
    reordered_a_2=dln_a(dln_a_s2_i);
    reordered_a_3=dln_a(dln_a_s3_i);

    reordered_a=vertcat(reordered_a_1,reordered_a_2,reordered_a_3);
end