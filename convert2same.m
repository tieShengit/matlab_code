function [img_fixed, img_moving] = convert2same(img1, img2)

% 获取每张图像的大小
[sizeY1, sizeX1, ~] = size(img1);
[sizeY2, sizeX2, ~] = size(img2);

% 找到最大的 X 值和 Y 值
maxX = max(sizeX1, sizeX2);
maxY = max(sizeY1, sizeY2);


% 创建填充后的新图像
img_fixed = zeros(maxY, maxX, size(img1, 3));
img_moving = zeros(maxY, maxX, size(img2, 3));

% 填充0
for k = 1:size(img1, 3)
    img_fixed(:,:,k) = 0;
end

for k = 1:size(img2, 3)
    img_moving(:,:,k) = 0;
end

% 将原始图像放置到新图像的左上角
img_fixed(1:sizeY1, 1:sizeX1, :) = img1;
img_moving(1:sizeY2, 1:sizeX2, :) = img2;

end
