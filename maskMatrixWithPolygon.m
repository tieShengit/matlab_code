function maskedMatrix = maskMatrixWithPolygon(matrix, coords)
    % matrix: 输入的矩阵
    % coords: 封闭轮廓的坐标点，2行N列矩阵，第一行是x坐标，第二行是y坐标

    % 获取矩阵的大小
    [rows, cols] = size(matrix);
    
    % 生成网格点
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % 检查网格点是否在多边形内
    inPolygon = inpolygon(X, Y, coords(1,:), coords(2,:));
    
    % 创建掩膜矩阵
    maskedMatrix = matrix;
    % 将多边形外的数据置为0
    maskedMatrix(~inPolygon) = 0; 
    
end
