clear all;
clc;

dilate_para = 1;
thresh1 = 'default';
thresh2 = 'default';

sampler = 'first';
fixed_mal_boundray = 'fixed_boundray.mat';
mids = {'M0','M1','M2','M3','M4'};

your_save_path = [];
save_folder = ['.//' sampler '/'];

if ~exist(['.//' sampler '/Malic/'],'dir')
    mkdir(['.//' sampler '/Malic/'])
else
    disp('---')
end

if ~exist(save_folder,'dir')
    mkdir(save_folder)
else
    disp('---')
end

% 参数名
para_name = 'mal_t1.mat';
save_path = [save_folder para_name];

% 使用路径读取excel内容
your_path = [];
fixed_matrix = readmatrix(your_path);
movimg_matrix = readmatrix(your_path);


fixed_m0_matrix = fixed_matrix / max(fixed_matrix(:));
movimg_m0_matrix = movimg_matrix / max(movimg_matrix(:));

fixed_non_zero = sort(fixed_m0_matrix(fixed_m0_matrix ~=0));
thresh1 = fixed_non_zero(floor(length(fixed_non_zero) * 0.35));

moving_non_zero = sort(movimg_m0_matrix(movimg_m0_matrix ~=0));
thresh2 = moving_non_zero(floor(length(moving_non_zero) * 0.3));

% 将两张图像填充成同样分辨率
[fixed_m0_matrix,movimg_m0_matrix] = convert2same(fixed_m0_matrix, movimg_m0_matrix);

% figure(1);
% imshow(fixed_m0_matrix);
% h1 = heatmap(fixed_m0_matrix,"Colormap",jet);
% h1.GridVisible = 'off';
% h1.XDisplayLabels = repmat({''},size(fixed_m0_matrix,2),1);
% h1.YDisplayLabels = repmat({''},size(fixed_m0_matrix,1),1);
% h1.ColorbarVisible = 'off';
% set(gca, 'position', [0 0 1 1]); %  'position', [0 0 1 1]
% title('预处理后的fixed图像');


% 图像预处理
threshsold = graythresh(movimg_m0_matrix);
[fixed_matrix_withbound,f_x,f_y] = get_numeric_array(fixed_m0_matrix,dilate_para,thresh1);
fix_img_boundary = [f_x'; f_y'];
[movimg_matrix_withbound,m_x,m_y] = get_numeric_array1(movimg_m0_matrix,dilate_para,thresh2);
moving_img_boundary = [m_x'; m_y'];

% 保存 fixed_m0 的闭包矩阵
fixed_mat_path = [save_folder fixed_mal_boundray];

if ~(exist(fixed_mat_path,'file') == 2)
%         load (t1_mal_m0_mat_path)
    save(fixed_mat_path,'fix_img_boundary')
    disp('fixed_mat 已保存')
else
    disp('fixed_mat 已存在')
end

% 显示预处理后的图像,以及处理的轮廓
figure(2);
subplot(121);
h1 = heatmap(fixed_matrix_withbound,"Colormap",jet);
h1.GridVisible = 'off';
h1.XDisplayLabels = repmat({''},size(fixed_matrix_withbound,2),1);
h1.YDisplayLabels = repmat({''},size(fixed_matrix_withbound,1),1);
h1.ColorbarVisible = 'off';
title('预处理后的fixed图像');
% set(gca, 'position', [0 0 1 1]);


% figure(3);
subplot(122);
h2 = heatmap(movimg_matrix_withbound,"Colormap",jet);
h2.GridVisible = 'off';
h2.XDisplayLabels = repmat({''},size(movimg_matrix_withbound,2),1);
h2.YDisplayLabels = repmat({''},size(movimg_matrix_withbound,1),1);
h2.ColorbarVisible = 'off';
% set(gca, 'position', [0 0 1 1]);
title('预处理后的moving图像');

figure(3);
subplot(121);
imshow(fixed_matrix_withbound);
% h1 = heatmap(fixed_matrix_withbound,"Colormap",jet);
% h1.GridVisible = 'off';
% h1.XDisplayLabels = repmat({''},size(fixed_matrix_withbound,2),1);
% h1.YDisplayLabels = repmat({''},size(fixed_matrix_withbound,1),1);
% h1.ColorbarVisible = 'off';
hold on; plot(f_x,f_y,'g','LineWidth',1);
% set(h1,'Color','none');
% title('fixed图像轮廓');
% set(gca, 'position', [0 0 1 1]);
hold off;

subplot(122);imshow(movimg_matrix_withbound);
% % h2 = heatmap(movimg_matrix_withbound,"Colormap",jet);
% % h2.GridVisible = 'off';
% % h2.XDisplayLabels = repmat({''},size(movimg_matrix_withbound,2),1);
% % h2.YDisplayLabels = repmat({''},size(movimg_matrix_withbound,1),1);
% % h2.ColorbarVisible = 'off';
% title('moving图像轮廓');
hold on; 
plot(m_x,m_y,'g','LineWidth',1);
hold off;

% 配准
% 创建两个cell 数组和两个ssim值数组来存储返回值
movingregCellArray1 = cell(1, 30);
ssimarray1 = single(zeros(1, 30));
movingregCellArray2 = cell(1, 30);
ssimarray2 = single(zeros(1, 30));

% 30次配准
for i = 1:30

% 返回的MOVINGREG对象包括配准后的图像、变换信息、位移场信息   
MOVINGREG1 = registerImages_com(movimg_matrix_withbound, fixed_matrix_withbound);
MOVINGREG2 = registerImages_geo(movimg_matrix_withbound, fixed_matrix_withbound);

% 图像信息
registered_img1 = MOVINGREG1.RegisteredImage;
registered_img2 = MOVINGREG2.RegisteredImage;

% 存储MOVINGREG对象
movingregCellArray1{i} = MOVINGREG1;
movingregCellArray2{i} = MOVINGREG2;

% 存储ssim值
ssimarray1(i) = ssim(im2gray(fixed_matrix_withbound),im2gray(registered_img1));
ssimarray2(i) = ssim(im2gray(fixed_matrix_withbound),im2gray(registered_img2));
end


% 分别找到两个数组中相似度的最大值和其位置
[maxValue1, maxIndex1] = max(ssimarray1);
[maxValue2, maxIndex2] = max(ssimarray2);
if maxValue1 >= maxValue2
    R1 = movingregCellArray1{maxIndex1};
    value1 = maxValue1;
    registered_best = R1.RegisteredImage;
    disp(['最大值为value1:', num2str(value1)])
    R1.Transformation.A
else
    R1 = movingregCellArray1{maxIndex2};
    value1 = maxValue2;
    registered_best = R1.RegisteredImage;
    disp(['最大值为value2:', num2str(value1)])
    R1.Transformation.A
end
movingRefObj = imref2d(size(movimg_matrix_withbound));
fixedRefObj = imref2d(size(fixed_matrix_withbound));
tform = R1.Transformation;

figure(4);
subplot(121);
h1 = heatmap(fixed_matrix_withbound,"Colormap",jet);
h1.GridVisible = 'off';
h1.XDisplayLabels = repmat({''},size(fixed_matrix_withbound,2),1);
h1.YDisplayLabels = repmat({''},size(fixed_matrix_withbound,1),1);
h1.ColorbarVisible = 'off';
title('fixed');

registered_best1 = imwarp(movimg_matrix_withbound, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true,'interp','nearest');
registered_best1 = imwarp(registered_best1, R1.DisplacementField,"nearest");

subplot(122);
h2 = heatmap(registered_best1,"Colormap",jet);
h2.GridVisible = 'off';
h2.XDisplayLabels = repmat({''},size(registered_best1,2),1);
h2.YDisplayLabels = repmat({''},size(registered_best1,1),1);
h2.ColorbarVisible = 'off';
title('movinged');

% 保存moving图像变换参数
save(save_path,'R1','moving_img_boundary')

