function cnt2 = smoothContour(cnt, ws)
% Smooth a polygonal contour by applying moving average filter.
%
%   CT2 = smoothContour(CT, F)
%   Quickly smooths the polygonal contour CT by averaging each element with
%   the F elements at his right and the F elements at his left. The
%   elements at the ends are also averaged but the extremes are 
%   left intact.
%
%
%   Example
%     ti = linspace(0.1, 0.9, 10)'; ti(end) = []; n = length(ti);
%     ti2 = linspace(0.9, 0.1, 10)'; ti2(end) = [];
%     xi = [ti ; 0.9*ones(n, 1) ; ti2 ; 0.1*ones(n, 1)];
%     yi = [0.1*ones(n, 1) ; ti ; 0.9*ones(n, 1) ; ti2];
%     poly = [xi yi];
%     figure; hold on;
%     drawPolygon(poly, 'k'); drawPoint(poly, 'k.');
%     poly2 = kymorod.core.geom.smoothContour(poly, 3);
%     drawPolygon(poly2, 'm');
%
%   Based on the "moving_average" function, 
%   by Carlos Adrin Vargas Aguilera. nubeobscura@hotmail.com
%
%   See also
%     smoothPolygon
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-07,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% Check input size
if ws > size(cnt, 1)
    error('Requires contour length greater than the smoothing window');
end

% expand coordinate array periodically
cnt = cnt([end-ws+1:end 1:end 1:ws], :);

% allocate memory for result
cnt2 = zeros(size(cnt));          

% initialize moving average
width = 2 * ws + 1;
cnt2(ws+1,:) = sum(cnt(1:width, :));

% recursive moving average
N = size(cnt, 1);
for iv = ws+2:N-ws
    cnt2(iv,:) = cnt2(iv-1,:) + cnt(iv+ws,:) - cnt(iv-ws-1,:);
end
cnt2 = cnt2 / width;

% remove trailing extremities
cnt2 = cnt2(ws+1:end-ws, :);
