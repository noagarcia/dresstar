function vec = compute_majority(X)

% X matrix where each row is a feature vector
% This function computes k-majority algorithm in binary data
% to fin the "cluster center" of X.

Xbinary = get_bits(X,8);
C = sum(Xbinary) >= 2;

% convert logical to double
numBytes = size(C,2)/8;
P2 = transpose(2 .^ (7:-1:0));
vec  = zeros(1,numBytes);

for iD = 1:numBytes
  aC    = C(iD*8-7:iD*8);
  vec(1,iD) = sum(aC' .* P2(9 - size(aC,2):8));
end

end