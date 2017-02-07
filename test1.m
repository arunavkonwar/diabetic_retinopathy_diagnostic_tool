clc;
close all;
clear all;
workspace; % Display workspace panel.
%filename = 'C:\Documents and Settings\tk2013\My Documents\Temporary
%stuff\fundus.jpg';
rgbImage = imread('3.jpg');
[rows columns numberOfColorPlanes] = size(rgbImage);
subplot(3, 3, 1);
imshow(rgbImage, []);
title('Original color Image');
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
tic;
redPlane = rgbImage(:, :, 1);
greenPlane = rgbImage(:, :, 2);
bluePlane = rgbImage(:, :, 3);
subplot(3, 3, 2);
imshow(redPlane, []);
title('Original Red Image');
subplot(3, 3, 3);
imshow(greenPlane, []);
title('Original Green Image');
subplot(3, 3, 4);
imshow(bluePlane, []);
title('Original Blue Image');

% Let's get the histogram of the green channel
[pixelCountsG GLs] = imhist(greenPlane);
% Ignore 0
pixelCountsG(1) = 0;
% Find where histogram falls to 10% of the peak, on the bright side.
tIndex = find(pixelCountsG >= 0.1*max(pixelCountsG), 1, 'last');
thresholdValue = GLs(tIndex)

binaryGreen = greenPlane > thresholdValue;
binaryImage = imfill(binaryGreen, 'holes');
% Get rid of blobs less than 5000 pixels.
binaryImage = bwareaopen(binaryImage, 5000);

subplot(3, 3, 5);
imshow(binaryGreen, []);
title('Binary Green Image');
%count number of objects
cc = bwconncomp(binaryGreen,4);
number  = cc.NumObjects;
fprintf('No of objects:%d\n', number);
pixelSum1 = bwarea(binaryGreen);
fprintf('Area of exudates:%d\n', pixelSum1);
labeledImage = bwlabel(binaryImage, 8); % Label each blob so we
%can make measurements of it
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); %
%pseudo random color labels

subplot(3, 3, 6); imagesc(coloredLabels);
title('Pseudo colored labels, from label2rgb()');

% Get all the blob properties. Can only pass in originalImage in
%version R2008a and later.
blobMeasurements = regionprops(labeledImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);
allBlobAreas = [blobMeasurements.Area];
allBlobPerimeters = [blobMeasurements.Perimeter];
allBlobECDs = allBlobPerimeters .^2 ./ (4 * pi * allBlobAreas)
allBlobSolidities = [blobMeasurements.Solidity]

binary2 = false(rows, columns);
for blobNumber = 1 : numberOfBlobs
chx = blobMeasurements(blobNumber).ConvexHull(:,1);
chy = blobMeasurements(blobNumber).ConvexHull(:,2);
binary2 = binary2 | poly2mask(chx,chy, rows, columns);
end
subplot(3, 3, 7);
imshow(binary2, []);
title('Convex Hull');

% Relabel and take the roundest one.
labeledImage = bwlabel(binary2, 8); % Label each blob so we can
%make measurements of it
blobMeasurements = regionprops(labeledImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);
allBlobAreas = [blobMeasurements.Area];
allBlobPerimeters = [blobMeasurements.Perimeter];
allBlobECDs = allBlobPerimeters .^2 ./ (4 * pi * allBlobAreas)
[roundestECDValue, roundestIndex] = min(allBlobECDs)

% Plot the optic nerve boundary on the original image.
subplot(3, 3, 8);
imshow(rgbImage, []);
title('Original color Image with optic nerve outlined');
chx = blobMeasurements(roundestIndex).ConvexHull(:,1);
chy = blobMeasurements(roundestIndex).ConvexHull(:,2);
hold on;
plot(chx, chy, 'linewidth', 3, 'color', [0 0 .7]);

subplot(3, 3, 9);
peaks(30);
title('A MATLAB demo by ImageAnalyst', 'FontSize', 14);