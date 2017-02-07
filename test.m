clc;
close all;
clear all;
workspace; % Display workspace panel.
% filename = 'C:\Documents and Settings\tk2013\My Documents\Temporary
% stuff\fundus.jpg';
rgbImage = imread('2.jpg');
[rows columns numberOfColorPlanes] = size(rgbImage);
subplot(3, 3, 1);
imshow(rgbImage, []);
title('Original color Image');
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
tic;
redPlane = rgbImage(:, :, 1);
greenPlane = rgbImage(:, :, 2);
figure,imshow(redPlane)
 K = imadjust(redPlane);
 figure
 imshow(K)
  SE = strel('rectangle',[7 5]);
BW3 = imdilate(K,SE);
 figure,imshow(BW3)
s=strel('square',12);
h=(imclose(BW3,s));
 figure,imshow(h)
      greenPlane=h;
   [pixelCountsG GLs] = imhist(greenPlane);
  % Ignore 0
  pixelCountsG(1) = 0;
  % Find where histogram falls to 10% of the peak, on the bright side.
  tIndex = find(pixelCountsG >= .1*max(pixelCountsG), 1, 'last');
  thresholdValue = GLs(tIndex)
binaryGreen = greenPlane>thresholdValue;
binaryImage = imfill(binaryGreen, 'holes');
% Get rid of blobs less than 5000 pixels.
binaryImage = bwareaopen(binaryImage, 5000);
figure,imshow(binaryGreen)