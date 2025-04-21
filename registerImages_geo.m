function [MOVINGREG] = registerImages_geo(MOVING,FIXED)

% 获得有限值数据的线性索引
finiteIdx = isfinite(FIXED(:));

% 将NaN值替换为0
FIXED(isnan(FIXED)) = 0;

% 将Inf值替换为1
FIXED(FIXED==Inf) = 1;

%将-Inf值替换为0
FIXED(FIXED==-Inf) = 0;

%将输入数据归一化到[0,1]范围内。
FIXEDmin = min(FIXED(:));
FIXEDmax = max(FIXED(:));
if isequal(FIXEDmax,FIXEDmin)
    FIXED = 0*FIXED;
else
    FIXED(finiteIdx) = (FIXED(finiteIdx) - FIXEDmin) ./ (FIXEDmax - FIXEDmin);
end

% 将moving图像归一化

% 获得有限值数据的线性索引
finiteIdx = isfinite(MOVING(:));

%将NaN值替换为0
MOVING(isnan(MOVING)) = 0;

% 将Inf值替换为1
MOVING(MOVING==Inf) = 1;

% 将-Inf值替换为0
MOVING(MOVING==-Inf) = 0;

% 归一化
MOVINGmin = min(MOVING(:));
MOVINGmax = max(MOVING(:));
if isequal(MOVINGmax,MOVINGmin)
    MOVING = 0*MOVING;
else
    MOVING(finiteIdx) = (MOVING(finiteIdx) - MOVINGmin) ./ (MOVINGmax - MOVINGmin);
end


% 默认空间引用对象
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% 基于强度的配准
[optimizer, metric] = imregconfig('multimodal');
metric.NumberOfSpatialSamples = 500;
metric.NumberOfHistogramBins = 50;
metric.UseAllPixels = true;
optimizer.GrowthFactor = 1.050000;
optimizer.Epsilon = 1.50000e-06;
optimizer.InitialRadius = 1.780e-03;
optimizer.MaximumIterations = 150;

% 几何中心对齐
fixedCenterXWorld = mean(fixedRefObj.XWorldLimits);
fixedCenterYWorld = mean(fixedRefObj.YWorldLimits);
movingCenterXWorld = mean(movingRefObj.XWorldLimits);
movingCenterYWorld = mean(movingRefObj.YWorldLimits);
translationX = fixedCenterXWorld - movingCenterXWorld;
translationY = fixedCenterYWorld - movingCenterYWorld;

% 粗对齐
initTform = affine2d();
initTform.T(3,1:2) = [translationX, translationY];

% 应用高斯模糊
fixedInit = imgaussfilt(FIXED,0.885);
movingInit = imgaussfilt(MOVING,0.885);

% 转换为灰度图
movingInit = mat2gray(movingInit);
fixedInit = mat2gray(fixedInit);

% 应用变换
tform = imregtform(movingInit,movingRefObj,fixedInit,fixedRefObj,'affine',optimizer,metric,'PyramidLevels',3,'InitialTransformation',initTform);
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true,'interp','nearest');

% 非刚性配准
[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = imregdemons(MOVINGREG.RegisteredImage,FIXED,120,'AccumulatedFieldSmoothing',1.2,'PyramidLevels',3);

% 存储空间参考对象
MOVINGREG.SpatialRefObj = fixedRefObj;

end

