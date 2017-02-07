%% Video Stabilization Using Point Feature Matching

clc;
close all;
clear all

A = imread('1.jpg'); % Read first frame into imgA
B = imread('2.jpg'); % Read second frame into imgB

imgA = rgb2gray(A);
imgB = rgb2gray(B);

figure; imshowpair(imgA, imgB, 'montage');
title(['Frame A', repmat(' ',[1 70]), 'Frame B']);

%%
figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
title('Color composite (frame A = red, frame B = cyan)');

%% Step 2. Collect Salient Points from Each Frame
%ptThresh = 0.1;
%pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
%pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);

pointsA =  detectSURFFeatures(imgA); %pointsA + detectMinEigenFeatures(imgA);
pointsB =  detectSURFFeatures(imgB); %pointsB + detectMinEigenFeatures(imgB);

%pointsA = detectBRISKFeatures(imgA);
%pointsB = detectBRISKFeatures(imgB);

% Display corners found in images A and B.
figure; imshow(imgA); hold on;
plot(pointsA);
title('Corners in A');

figure; imshow(imgB); hold on;
plot(pointsB);
title('Corners in B');

%% 
[featuresA, pointsA] = extractFeatures(imgA, pointsA);
[featuresB, pointsB] = extractFeatures(imgB, pointsB);

%%
indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

%%

figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
legend('A', 'B');

%% Step 4. Estimating Transform from Noisy Correspondences

[tform, pointsBm, pointsAm] = estimateGeometricTransform(...
    pointsB, pointsA, 'affine');
imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
pointsBmp = transformPointsForward(tform, pointsBm.Location);

%%

figure;
showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
legend('A', 'B');

%% Step 5. Transform Approximation and Smoothing

% % Extract scale and rotation part sub-matrix.
% H = tform.T;
% R = H(1:2,1:2);
% % Compute theta from mean of two possible arctangents
% theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% % Compute scale from mean of two stable mean calculations
% scale = mean(R([1 4])/cos(theta));
% % Translation remains the same:
% translation = H(3, 1:2);
% % Reconstitute new s-R-t transform:
% HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
%   translation], [0 0 1]'];
% tformsRT = affine2d(HsRt);
% 
% imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
% imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));
% 
% figure(2), clf;
% imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
% title('Color composite of affine and s-R-t transform outputs');

w1 = zeros(1:1944, 1:2592, 'uint8');
for i=1:1944
    for j=1:2592
        b = imgA(i, j);
        c = imgBp(i, j);
        w1(i, j) = min(b,c);            
    end
end

figure, clf;
imshow(w1);
title('Stitched Image (Final)');

