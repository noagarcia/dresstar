function [descriptorsN1, keypointsN1, idTrackN1, countTrack, countFeature] = ...
    compute_tracking(descriptors, keyPoints, descriptorsN1, keypointsN1, idTrackN1, ...
    countFrame, countTrack, countFeature, dirTracks, opts)

if countFrame == 1
    descriptorsN1 = descriptors;
    keypointsN1 = keyPoints;

    % idTrack matrix <idTrack; idFeature; idFrame; idWithinFrame>
    idTrackN1 = [countTrack:countTrack+size(descriptorsN1,1)-1; countFeature:countFeature+size(descriptorsN1,1)-1]';
    idTrackN1(:,end+1) = countFrame;
    idTrackN1(:,end+1) = countTrack:countTrack+size(descriptorsN1,1)-1;

    % choose file to save
    ifiletracks = floor(countFrame/opts.maxFramesFile)+1;
    fileTracksName = sprintf('%sTracks_%04d.txt', dirTracks, ifiletracks);
    dlmwrite(fileTracksName, idTrackN1, 'delimiter',' ', 'precision', 10);

    % update counters
    countFeature = countFeature+size(descriptorsN1,1);
    countTrack = countTrack+size(descriptorsN1,1);
else
    descriptorsN2 = descriptors;
    keypointsN2 = keyPoints;

    % Get matches between two consecutive images
    spatial_matches = match2images(descriptorsN1, keypointsN1, descriptorsN2, keypointsN2, opts);

    % Assign idTrack to features
    idTrackN2 = zeros(size(descriptorsN2,1),3);
    for ifeat = 1:size(descriptorsN2,1)

        if ~isempty(spatial_matches)
            indx = ismember([spatial_matches.trainIdx]+1,ifeat);
            N1matched = [spatial_matches(indx).queryIdx]+1;
            Track = idTrackN1(ismember(idTrackN1(:,4),N1matched),1);
        else
            Track = [];
        end

        if ~isempty(Track)
            idTrackN2(ifeat,1) = Track;
        else
            idTrackN2(ifeat,1) = countTrack; countTrack = countTrack + 1;
        end

        idTrackN2(ifeat,2) = countFeature; countFeature = countFeature + 1;
        idTrackN2(ifeat,3) = countFrame;
        idTrackN2(ifeat,4) = ifeat;
    end

    % Write matrix into a file such as <idTrack; idFeatures; idFrame>

    % choose file to save
    ifiletracks = floor(countFrame/opts.maxFramesFile)+1;
    fileTracksName = sprintf('%sTracks_%04d.txt', dirTracks, ifiletracks);
    dlmwrite(fileTracksName, idTrackN2, '-append', 'delimiter',' ', 'precision', 10);

    % Update descriptors
    descriptorsN1 = descriptorsN2;
    keypointsN1 = keypointsN2;
    idTrackN1 = idTrackN2;
end

end


% --------------------------------------------------------------------
function matches = match2images(descriptorsN1, keypointsN1, descriptorsN2, keypointsN2, opts)
% --------------------------------------------------------------------

matcher = cv.DescriptorMatcher('BFMatcher', 'NormType', ...
    'Hamming','CrossCheck', true);

matches = []; 
if (size(descriptorsN1, 2) == size(descriptorsN2, 2)) ...
        && (size(descriptorsN2, 1) > 0) ...
        && (size(descriptorsN1, 1) > 0)
    
    % match descriptors
    ms = matcher.match(descriptorsN1, descriptorsN2);
    indexPairs = [ms.distance]' < opts.distFeat;
    current_matches = ms(indexPairs);
       
    % spatial filter
    Point_cell = arrayfun(@(x) [num2cell([x.pt])], keypointsN1([current_matches.queryIdx]+1), 'UniformOutput', 0);
    Point_cell = vertcat(Point_cell{:});
    v1 = cell2mat(Point_cell);
    Point_cell = arrayfun(@(x) [num2cell([x.pt])], keypointsN2([current_matches.trainIdx]+1), 'UniformOutput', 0);
    Point_cell = vertcat(Point_cell{:});
    v2 = cell2mat(Point_cell);
    
    distVECT = diag(pdist2(v1,v2));
    matches = current_matches(distVECT < opts.distPix);    
end

end