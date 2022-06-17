function result=stata_unique(data)
    result=nrow(unique(data)(:));
end