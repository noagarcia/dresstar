function bits = get_bits(A,N)
  % Gets the N lowest bits from each element of A
  B = zeros([size(A) 0]);
  nDims = ndims(A)+1;
  for iBit = N:-1:1
    B = cat(nDims,B,bitget(A,iBit));
  end
  
  [n d] = size(A);
  aux = permute(B,[1 3 2]);
  bits = logical(reshape(aux, n, d*N));
end