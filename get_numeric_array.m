function [num_array,x_l,y_l] = get_numeric_array(matrix,dilate_para,thresh)

     img_num = matrix;
    
%      二值化
    threshsold = graythresh(img_num);
    if thresh == 'default'
        img_bw = imbinarize(matrix,threshsold);
    else 
        img_bw = imbinarize(matrix,thresh);
    end
 
%     处理
    img_bw = imfill(img_bw,'holes');
    img_bw = imopen(img_bw, strel('disk',2));
    img_bw = imdilate(img_bw,strel("disk",dilate_para));

%     获取轮廓
    max_length = 0;
    longest_array_index = 1;
    [B,L ]= bwboundaries(img_bw,'noholes');
    for i = 1:length(B)
        current_array = B{i};
        current_length = length(current_array);
        if current_length > max_length
            max_length = current_length;
            longest_array_index = i;
        end
    end
    longest_boundry = B{longest_array_index};
    xlim = longest_boundry(:,2);
    ylim = longest_boundry(:,1);
    k1 = boundary(xlim, ylim,0.1);
    b1 = longest_boundry(k1,:);
    x_l = b1(:, 2);
    y_l = b1(:, 1);
    bound = [x_l'; y_l'];

    % 保留轮廓内的图像
    num_array = maskMatrixWithPolygon(img_num, bound);

end