function maskedMatrix = maskMatrixWithPolygon(matrix, coords)
% maskMatrixWithPolygon - Mask a matrix by setting values outside a polygon to zero.
%
% Inputs:
%   matrix - Input 2D matrix.
%   coords - 2xN array of polygon coordinates, where:
%            coords(1,:) are x-coordinates,
%            coords(2,:) are y-coordinates.
%
% Outputs:
%   maskedMatrix - Matrix where values outside the polygon are set to zero.

% Get the size of the input matrix
[rows, cols] = size(matrix);

% Generate coordinate grid
[X, Y] = meshgrid(1:cols, 1:rows);

% Determine points inside the polygon
inPolygon = inpolygon(X, Y, coords(1,:), coords(2,:));

% Create the masked matrix
maskedMatrix = matrix;
maskedMatrix(~inPolygon) = 0; % Set values outside the polygon to zero

end
