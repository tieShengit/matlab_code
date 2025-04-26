function [MOVINGREG] = registerImages_com(MOVING,FIXED)

% Get the linear indices of finite values
finiteIdx = isfinite(FIXED(:));

% Replace NaN values with 0
FIXED(isnan(FIXED)) = 0;

% Replace Inf values with 1
FIXED(FIXED==Inf) = 1;

% Replace -Inf values with 0
FIXED(FIXED==-Inf) = 0;

% Normalize the input data to the range [0,1]
FIXEDmin = min(FIXED(:));
FIXEDmax = max(FIXED(:));
if isequal(FIXEDmax,FIXEDmin)
    FIXED = 0*FIXED;
else
    FIXED(finiteIdx) = (FIXED(finiteIdx) - FIXEDmin) ./ (FIXEDmax - FIXEDmin);
end

% Normalize the moving image

% Get the linear indices of finite values
finiteIdx = isfinite(MOVING(:));

% Replace NaN values with 0
MOVING(isnan(MOVING)) = 0;

% Replace Inf values with 1
MOVING(MOVING==Inf) = 1;

% Replace -Inf values with 0
MOVING(MOVING==-Inf) = 0;

% Normalize
MOVINGmin = min(MOVING(:));
MOVINGmax = max(MOVING(:));
if isequal(MOVINGmax,MOVINGmin)
    MOVING = 0*MOVING;
else
    MOVING(finiteIdx) = (MOVING(finiteIdx) - MOVINGmin) ./ (MOVINGmax - MOVINGmin);
end

% Default spatial reference object
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% Intensity-based registration
[optimizer, metric] = imregconfig('multimodal');
metric.NumberOfSpatialSamples = 500;
metric.NumberOfHistogramBins = 50;
metric.UseAllPixels = true;
optimizer.GrowthFactor = 1.050000;
optimizer.Epsilon = 1.50000e-06;
optimizer.InitialRadius = 1.780e-03;
optimizer.MaximumIterations = 150;

% Center of mass alignment
[xFixed,yFixed] = meshgrid(1:size(FIXED,2),1:size(FIXED,1));
[xMoving,yMoving] = meshgrid(1:size(MOVING,2),1:size(MOVING,1));
sumFixedIntensity = sum(FIXED(:));
sumMovingIntensity = sum(MOVING(:));
fixedXCOM = (fixedRefObj.PixelExtentInWorldX .* (sum(xFixed(:).*double(FIXED(:))) ./ sumFixedIntensity)) + fixedRefObj.XWorldLimits(1);
fixedYCOM = (fixedRefObj.PixelExtentInWorldY .* (sum(yFixed(:).*double(FIXED(:))) ./ sumFixedIntensity)) + fixedRefObj.YWorldLimits(1);
movingXCOM = (movingRefObj.PixelExtentInWorldX .* (sum(xMoving(:).*double(MOVING(:))) ./ sumMovingIntensity)) + movingRefObj.XWorldLimits(1);
movingYCOM = (movingRefObj.PixelExtentInWorldY .* (sum(yMoving(:).*double(MOVING(:))) ./ sumMovingIntensity)) + movingRefObj.YWorldLimits(1);
translationX = fixedXCOM - movingXCOM;
translationY = fixedYCOM - movingYCOM;

% Rough alignment
initTform = affine2d();
initTform.T(3,1:2) = [translationX, translationY];

% Apply Gaussian blur
fixedInit = imgaussfilt(FIXED,0.885);
movingInit = imgaussfilt(MOVING,0.885);

% Convert to grayscale
movingInit = mat2gray(movingInit);
fixedInit = mat2gray(fixedInit);

% Apply transformation
tform = imregtform(movingInit,movingRefObj,fixedInit,fixedRefObj,'affine',optimizer,metric,'PyramidLevels',3,'InitialTransformation',initTform);
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true,'interp','nearest');

% Non-rigid registration
[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = imregdemons(MOVINGREG.RegisteredImage,FIXED,120,'AccumulatedFieldSmoothing',1.2,'PyramidLevels',3);

% Store spatial reference object
MOVINGREG.SpatialRefObj = fixedRefObj;

end
