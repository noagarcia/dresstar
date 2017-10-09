function [indicesSorted, distances] = binary_sort(indices, X, value)
    
dist = sum(  bsxfun(@ne,value,X) , 2);
[~, ind]=sort(dist);
indicesSorted = indices(ind)';
distances = dist(ind);

end



