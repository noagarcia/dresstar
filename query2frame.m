function [frame, videoName] = query2frame(query, dataDir, optsin)

% QUERY2FRAME 
%   processes queries and find the most similar frame in the dataset of
%   videos.
%
%   Example:
%     query = imread('/path/to/query.png');
%     dataDir  = '~/data/';
%     query2frame(query, dataDir);
%   
%   Inputs: 
%     query:        query image
%     dataDir:      full path to directory where data is being stored
%     optsin:       A struct containing the values of the method.
%     - opts.width:             frame width [720]
%     - opts.distFeat:          maximum value distance between features [20]
%     - opts.sl                 size of leaf nodes in the kdtree [100]
%     - opts.B                  number of backtraking steps [50]
%
%   Outputs: 
%     frame:        retrieved frame number
%     videoName:    name of the retrieved video
%
%   MATLAB code for "Dress lika a Star: Retrieving Fashion Products from Videos"
%
%   Citation:
%     N. Garcia, G. Vogiatzis. Dress like a Star: Retrieving Fashion Products from Videos. In ICCVW 2017.

addpath('src/');

% Parameters
opts.width = 720;
opts.distFeat = 20;
opts.sl = 100;
opts.B = 50;

if nargin == 3  
    s_merged = rmfield(opts, intersect(fieldnames(opts), fieldnames(optsin)));
    names = [fieldnames(s_merged); fieldnames(optsin)];
    opts = cell2struct([struct2cell(s_merged); struct2cell(optsin)], names, 1);
end

% Opencv Init
matcher = cv.DescriptorMatcher('BruteForce-Hamming');
detector = cv.FeatureDetector('ORB');
extractor = cv.DescriptorExtractor('BriefDescriptorExtractor');

% Load Data
[featuresTrain, indexMatTotal, tree, videoList] = dataLoader(dataDir);

% Extract features from query
[~, qDescriptor] = compute_features(query, detector, extractor, opts);
qDescriptor_bits = get_bits(qDescriptor,8);

% For each feature, search its nearest neighbours in the tree
indxs = zeros(size(qDescriptor_bits,1)*opts.B*opts.sl,1); inxCount = 1;
for i=1:size(qDescriptor_bits,1)
    index_vals = search_kdtree(tree, qDescriptor_bits(i,:), opts.sl, opts.B);
    candidateVectors = get_bits(featuresTrain(index_vals, :),8);
    [index_vals, dist_vals] = binary_sort(index_vals, candidateVectors, qDescriptor_bits(i,:));
    newFeat = index_vals(1:sum(dist_vals(:) == dist_vals(1))); 
    newinx = inxCount +  size(newFeat,2);
    indxs(inxCount:newinx-1) = newFeat';
    inxCount = newinx;
end
indxs(indxs==0) = [];

% Count votes for shots
shotVotes = indexMatTotal(indxs, 2:3);
if isempty(shotVotes)
    return;
end
[voted_shot, videoId] = count_votes_shots(shotVotes);
videoName = videoList{2}{videoId};
fprintf('Image from video.... %s. \n', videoName);   

% Frames within the most voted shot
dirBin = fullfile(dataDir, videoName, 'Binary/');
load(fullfile(dataDir, videoName, 'shots.mat'),'shots');
firstFrame = shots(voted_shot,2);
lastFrame = shots(voted_shot,3);

% Brute Force Search
MaxMatches = 0; frame = 0;
for iframe = firstFrame:lastFrame   
    load(sprintf('%sframe%08d.mat', dirBin, iframe),'descriptors');
    if (size(qDescriptor, 2) == size(descriptors, 2)) ...
            && (size(descriptors, 1) > 0) ...
            && (size(qDescriptor, 1) > 0)
        matches = matcher.match(qDescriptor, descriptors);
        indexPairs = [matches.distance]' < opts.distFeat;
        num_matches = size([matches(indexPairs).queryIdx],2);
        if(num_matches > MaxMatches)
            MaxMatches = num_matches; 
            frame = iframe;
        end
    end
end
fprintf('Frame number.... %d. \n', frame); 
    
end


% --------------------------------------------------------------------
function [featuresTrain, indexMatTotal, tree, videoList] = dataLoader(dataDir)
% --------------------------------------------------------------------

featuresMatrixFile = fullfile(dataDir, 'KeyFeatures.mat');
load(featuresMatrixFile,'keyfeaturesTotal', 'indexMatTotal');
featuresTrain = uint8(keyfeaturesTotal);

treeFile = fullfile(dataDir, 'tree.mat');
load(treeFile,'tree');

fileID = fopen(fullfile(dataDir, 'moviesIds.txt'));
videoList = textscan(fileID,'%d %s');
fclose(fileID);

end