function [keyfeaturesTotal, indexMatTotal, tree] = training(videoDir, dataDir, optsin)

% TRAINING 
%   processes videos allocated in directory videosDir and saves data into
%   directory dataDir.
%
%   Example:
%     videoDir = '~/videos/';
%     dataDir  = '~/data/';
%     training(videoDir, dataDir);
%   
%   Inputs: 
%     movieDir:     full path to directory with videos
%     dataDir:      full path to directory where data is going to be saved
%     optsin:       A struct containing the values of the method.
%     - opts.width:             frame width [720]
%     - opts.minIntersection:   minimum number of features in common
%                               between consecutive frames [1]
%     - opts.distFeat:          maximum value distance between features [20]
%     - opts.distPix:           maximum pixel distance between features [100]
%     - opts.minTrackLength     minimum number of frames in a track [7]
%     - opts.thumbs             bool to save thumbnails of the video frames [false]
%     - opts.thumbsRes          ressolution of thumbnail images [160]
%     - opts.sl                 size of leaf nodes in the kdtree [100]
%
%   MATLAB code for "Dress lika a Star: Retrieving Fashion Products from Videos"
%   This version of the code is not optimized to run efficiently
%
%   Citation:
%     N. Garcia, G. Vogiatzis. Dress like a Star: Retrieving Fashion Products from Videos. In ICCVW 2017.

addpath('src/');

% Parameters
opts.width = 720;
opts.minIntersection = 1;
opts.distFeat = 20;
opts.distPix = 100;
opts.maxFramesFile = 1500;
opts.minTrackLength = 7;
opts.thumbs = false;
opts.thumbsRes = 160;
opts.sl = 100;

if nargin == 3  
    s_merged = rmfield(opts, intersect(fieldnames(opts), fieldnames(optsin)));
    names = [fieldnames(s_merged); fieldnames(optsin)];
    opts = cell2struct([struct2cell(s_merged); struct2cell(optsin)], names, 1);
end

% OpenCV init
detector = cv.FeatureDetector('ORB');
extractor = cv.DescriptorExtractor('BriefDescriptorExtractor');

% Output vars and counters
moviefileID = fopen(fullfile(dataDir, 'moviesIds.txt'),'wt');
movieId = 1; indexkeyfeature = 0;
keyfeaturesTotal = []; indexMatTotal = [];

% Loop for every file in videoDir
lsvid = dir(fullfile(videoDir));
for ivid = 1:length(lsvid)
    
    % Check if it is a file
    try
        mmfileinfo(fullfile(videoDir, lsvid(ivid).name));
        avifile = fullfile(videoDir, lsvid(ivid).name);
        mov = VideoReader(avifile);
    catch
        continue;
    end    
    fprintf('Reading video %s. \n', lsvid(ivid).name);   
    [~,videoName,~] = fileparts(lsvid(ivid).name);
     
    % Create data directories
    mkdir(dataDir, videoName);
    dirBin = fullfile(dataDir, videoName, 'Binary/'); mkdir(dirBin);
    dirTracks = fullfile(dataDir, videoName, 'Tracks/'); mkdir(dirTracks);
    if opts.thumbs
        dirThumbs = fullfile(dataDir, videoName, 'Thumbs/'); mkdir(dirThumbs);
    end
    
    % Tracking counters
    countFeature = 1;
    countTrack = 1;
    
    % Read video file
    fprintf('    Extracting features...');
    ii = 0;
    while hasFrame(mov)

        % Get frame
        ii = ii + 1;
        if ~mod(ii,24)
            fprintf('.');
        end
        frame = readFrame(mov);

        % Get features
        [keyPoints, descriptors] = compute_features(frame, ...
                    detector, extractor, opts);
        save(sprintf('%sframe%08d.mat', dirBin, ii), 'descriptors', 'keyPoints');

        % Save thumbnail
        if opts.thumbs
            frame = imresize(frame, [NaN opts.thumbsRes]);
            imwrite(frame, sprintf('%sframe%08d.png', dirThumbs, ii));
        end
        clearvars frame;
        
        % Tracking
        if ii == 1
            [descriptorsN1, keypointsN1, idTrackN1, countTrack, countFeature] = ...
                    compute_tracking(descriptors, keyPoints, [], [], [], ...
                    ii, countTrack, countFeature, dirTracks, opts);
        else
            [descriptorsN1, keypointsN1, idTrackN1, countTrack, countFeature] = ...
                    compute_tracking(descriptors, keyPoints, descriptorsN1, keypointsN1, idTrackN1, ...
                    ii, countTrack, countFeature, dirTracks, opts);
        end
        
        % Clear variables
        clearvars descriptors keyPoints;

    end
    fprintf('Done\n');
    
    % Shots
    fprintf('    Detecting shots...');
    shots = detect_shots(dirTracks, opts.minIntersection);
    save(fullfile(dataDir, videoName, 'shots.mat'),'shots');
    fprintf('Done\n');

    % Keyfeatures
    fprintf('    Extracting keyfeatures...');
    [featuresShot, indexMat] = compute_keyfeatures(dirTracks, shots, dirBin, opts);
    rmdir(dirTracks, 's');
       
    % Create unique keyfeature matrix for all videos
    if ~isempty(featuresShot)
        keyfeaturenumber = [indexkeyfeature+1:indexkeyfeature+size(featuresShot,1)]';
        shotnumber = indexMat(:,2); % assign idShot in movie
        movienumber(1:size(featuresShot,1),1) = movieId; % assign movie id         
        indexMatTotal(end+1:end+size(featuresShot,1),:) = ...
            [keyfeaturenumber shotnumber movienumber]; % correspondence between feature numbers and shot number
        keyfeaturesTotal(end+1:end+size(featuresShot,1),:) = featuresShot; % assign features to feature matrix
        indexkeyfeature = indexkeyfeature + size(featuresShot,1); % update
        fprintf(moviefileID, '%d %s\n', movieId, videoName); % write data
        movieId = movieId + 1;
        clearvars movienumber;
    end          
    clearvars featuresShot indexMat;
    fprintf('Done\n');
    
end

% Build kdtree & save
fprintf('Building kdtree...');
tree = build_kdtree(keyfeaturesTotal, opts.sl);
featuresMatrixFile = fullfile(dataDir, 'KeyFeatures.mat');
treeFile = fullfile(dataDir, 'tree.mat');
save(featuresMatrixFile,'keyfeaturesTotal', 'indexMatTotal');
save(treeFile,'tree');
fprintf('Done\n');

end



