function [num_array, x_l, y_l] = get_numeric_array1(matrix, dilate_para, thresh)

    img_num = matrix;
    
    % Binarization
    threshsold = graythresh(img_num);
    if strcmp(thresh, 'default')
        img_bw = imbinarize(matrix, threshsold);
    else 
        img_bw = imbinarize(matrix, thresh);
    end
 
    img_bw = imfill(img_bw, 'holes');
    img_bw = imopen(img_bw, strel('disk', 2));
    img_bw = imdilate(img_bw, strel('disk', dilate_para));

    max_length = 0;
    longest_array_index = 1;
    [B, L] = bwboundaries(img_bw, 'noholes');
    for i = 1:length(B)
        current_array = B{i};
        current_length = length(current_array);
        if current_length > max_length
            max_length = current_length;
            longest_array_index = i;
        end
    end
    longest_boundary = B{longest_array_index};
    xlim = longest_boundary(:,2);
    ylim = longest_boundary(:,1);
    k1 = boundary(xlim, ylim, 0.1);
    b1 = longest_boundary(k1,:);
    x_l = b1(:,2);
    y_l = b1(:,1);
    bound = [x_l'; y_l'];

    % Retain the image inside the contour
    num_array = maskMatrixWithPolygon(img_num, bound);

end
