function [keyfeaturesShot, indexMat] = compute_keyfeatures(tracksFilesPath, shots, featuresPath, opts)

% <idTrack idFeature idFrame idWithinFrame>
F = dir([tracksFilesPath, '*.txt']);
ifiletracks = 1;
tracks = load([tracksFilesPath, F(ifiletracks).name]);

indexkeyfeature = 0;
keyfeaturesShot = []; indexMat = [];
totalShots = size(unique(shots(:,1)));
for shotk=1:totalShots

    % Select shot and its info
    firstFrame = shots(shotk,2);
    lastFrame = shots(shotk,3);
    
    % Load features for all the frames in that shot
    featuresShot = [];
    for iframe = firstFrame:lastFrame
        load(sprintf('%sframe%08d.mat', featuresPath, iframe), 'descriptors');
        numFeat = size(descriptors,1);

        if numFeat>0
            framenumber(1:numFeat,1) = iframe;
            featuresShot(end+1:end+numFeat,:) = [double(descriptors) framenumber];
        end
        clearvars framenumber descriptors;
    end
    
    % Load tracks
    shotMatrix = tracks(ismember(tracks(:,3), firstFrame:lastFrame),:);
    while isempty(shotMatrix) || shotMatrix(end,3) ~= lastFrame
        ifiletracks = ifiletracks + 1;
        tracks = load([tracksFilesPath, F(ifiletracks).name]);
        shotMatrix = [shotMatrix;tracks(ismember(tracks(:,3), firstFrame:lastFrame),:)];
    end

    % Remove weak tracks
    [length, track]=hist(shotMatrix(:,1),unique(shotMatrix(:,1)));
    ind = length <= opts.minTrackLength;
    length(ind) = []; track(ind) = [];

    % Compute key features
    if ~isempty(track)
        
        % K-Majority to select a feature per track
        keyFeatures = zeros(size(track,1), 32);
        for iTrack = 1:size(track,1)
            numtrack = track(iTrack);
            featuresnum = shotMatrix(ismember(shotMatrix(:,1),numtrack),3:4); % <idFrame idWithinFrame>

            % load features
            features = zeros(size(featuresnum,1), 32);
            for iFrame = 1:size(featuresnum,1)
                framenum = featuresnum(iFrame,1);
                descriptors = featuresShot(find(featuresShot(:,end) == framenum),1:end-1);
                features(iFrame,:) = descriptors(featuresnum(iFrame,2),:); 
            end
            keyFeatures(iTrack,:) = compute_majority(features);
        end
        keyFeatures = uint8(keyFeatures);

        % Save key features shot
        if ~isempty(keyFeatures)
            shotnumber(1:size(keyFeatures,1),1) = shotk;
            featurenumber = [indexkeyfeature+1:indexkeyfeature+size(keyFeatures,1)]';
            keyfeaturesShot(end+1:end+size(keyFeatures,1),:) = keyFeatures;
            indexMat(end+1:end+size(keyFeatures,1),:) = [featurenumber shotnumber];
            indexkeyfeature = indexkeyfeature + size(keyFeatures,1);            
            clearvars featurenumber shotnumber;
        end

    end
end

end