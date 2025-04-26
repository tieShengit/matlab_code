function [img_fixed, img_moving] = convert2same(img1, img2)

% Get the size of each image
[sizeY1, sizeX1, ~] = size(img1);
[sizeY2, sizeX2, ~] = size(img2);

% Find the maximum X and Y values
maxX = max(sizeX1, sizeX2);
maxY = max(sizeY1, sizeY2);

% Create new padded images initialized with zeros
img_fixed = zeros(maxY, maxX, size(img1, 3));
img_moving = zeros(maxY, maxX, size(img2, 3));

% Place the original images at the top-left corner of the new images
img_fixed(1:sizeY1, 1:sizeX1, :) = img1;
img_moving(1:sizeY2, 1:sizeX2, :) = img2;

end
