function [voted_shot, voted_movie] = count_votes_shots(shotMatrix)

% shotMatrix is a matrix where each row is a voted shot and movie.
% First column is shot id and second column is movieid
% The function returns the most voted shot and its movieid.

listMovies = unique(shotMatrix(:,2));

matrixShotID = repmat(shotMatrix(:,1), 1, length(listMovies));
matrixMoviesID = repmat(shotMatrix(:,2), 1, length(listMovies));
matrixListMovies = repmat(listMovies', size(shotMatrix,1), 1);

matrixShotID(matrixMoviesID ~= matrixListMovies) = NaN;
[shots, freq] = mode(matrixShotID);
[~, index] = max(freq);
voted_shot = shots(index);
voted_movie = listMovies(index);

end