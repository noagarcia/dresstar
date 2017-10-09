function shots = detect_shots(tracksFilesPath, minIntersection)

F = dir([tracksFilesPath, '*.txt']);
shots = [];
idshot = 1;
for ii = 1:length(F)
    
    tracks = load([tracksFilesPath, F(ii).name]); %<idTrack idFeature idFrame idWithinFrame>
    finalFrame = tracks(end,3);
    
    if ii == 1
        firstFrame = tracks(1,3);
        N1 = tracks(ismember(tracks(:,3), firstFrame),1);        
    end
    
    for j=tracks(1,3):finalFrame-1
        N2 = tracks(ismember(tracks(:,3), j+1),1);
        intersection = intersect(N1,N2);
        sizeIntersection = length(intersection);
        if sizeIntersection <= minIntersection 
            lastFrame = j;

            if ~isempty(N1) % only write if frames are not empty
                shots = [shots; [idshot firstFrame lastFrame]];
                idshot = idshot+1;
            end
            firstFrame = j+1;
        end
        N1 = N2;
    end

end
shots = [shots; [idshot firstFrame finalFrame]];
