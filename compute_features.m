function [keyPoints, descriptors] = compute_features(frameColor, detector, extractor, opts)

% Preprocess
if size(frameColor, 3) == 3
    frame = rgb2gray(frameColor);
end
frame = imresize(frame, [NaN opts.width]);

% Binary features
keyPoints = detector.detect(frame);
descriptors = extractor.compute(frame, keyPoints);

end