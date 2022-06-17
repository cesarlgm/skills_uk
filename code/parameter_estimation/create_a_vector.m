function result=create_a_vector(restricted_a)
    full_size=4/3*size(restricted_a,1);
    full_a=zeros(full_size,1);
    
    index=mod(transpose(1:full_size),4);

    full_a(index~=0,:)=restricted_a;

    result=full_a;
end