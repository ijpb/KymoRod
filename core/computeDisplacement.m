function E = computeDisplacement(skel1, skel2, S1, S2, img1, img2, ws, L)
%COMPUTEDISPLACEMENT Compute displacement between two skeletons in pixel coordinates
% 
%   E = computeDisplacement(SK1, SK2, S1, S2, IMG1, IMG2, WS, L)
%   (rewritten from function 'elong5')
%   Compute displacement between two frames, given skeleton in each frame
%   (in pixel coordinates), curvilinear abscissa for each skeleton,
%   reference image for each frame, size of correlation window, and
%   threshold on the maximal difference in curvilinear abscissa between the
%   two skeletons.
%   
%   Input arguments:
%   SK1: 	skeleton associated to first frame
%   SK2: 	skeleton associated to second frame
%   S1: 	curvilinear abscissa of first frame skeleton
%   S2: 	curvilinear abscissa of second frame skeleton
%   IMG1: 	image of the first frame
%   IMG2: 	image of the second frame
%   WS: 	size of the correlation window (in pixels)
%   L:      max difference in curvilinear abscissa (in user unit)
%
%   Output arguments:
%   E:      a N-by-2 array, containing for each vertex the curvilinear
%           abscissa and the displacement (difference in curvilinear
%           abscissa) 
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

dim = size(img1);

% identify in each image the pixels containing a portion of skeleton
% S1pix and S2pix contain curvilinear abscissa for corresponding pixels.
[x1, y1, S1pix] = snapFunctionToPixels(img1, skel1, S1);
[x2, y2, S2pix] = snapFunctionToPixels(img2, skel2, S2);

% allocate memory for result
E = zeros(length(x1), 2);

% counter for number of computed correlations
a = 0;

% apply Particle Image Velocimetry on each point of the skeleton
for k = 1:length(x1)
	% image indices of current point
    i = y1(k);
    j = x1(k);
   
    % process only skeleton points that are not too close from border
    if i <= ws || j <= ws || i >= (dim(1)-ws) || j >= (dim(2)-ws)
        continue;
    end
    
    % get small image around current point of first skeleton
    w1 = double(img1(i-ws:i+ws, j-ws:j+ws));
    
    % compute PIV only if variability in window is sufficient
    V = std2(w1);
    if V <= 1
        continue;
    end
        
    % transform to vector, and remove mean
    w1 = w1(:) - mean(w1(:));
    
    % identify positions in second image with similar curvilinear abscissa
    % TODO: keep second condition?
    inds = find( abs(S2pix - S1pix(k)) < L & S2pix > 0);
    x2k = x2(inds);
    y2k = y2(inds);
    S2k = S2pix(inds);

    % process only neighbor points that are not too close from border
    inds = (x2k > ws) & (x2k < dim(2)-ws) & (y2k > ws) & (y2k < dim(1)-ws);
    x2k = x2k(inds);
    y2k = y2k(inds);
    S2k = S2k(inds);
    
    % check degenerate cases
    if isempty(x2k)
        error('Could not find enough points in second skeleton close to point (%d,%d)', j, i);
    end
    
    % initialze result of image to image correlation
    resCorr = zeros(length(x2k), 2);
    
    % iterate over pixels of second skeleton close enough from current pixel
    for l = 1:length(x2k)
        % indices of positions in second image
        u = y2k(l);
        v = x2k(l);
        
        % get small image around current point in second skeleton
        w2 = double(img2(u-ws:u+ws, v-ws:v+ws));
        
        % transform to vector, and remove mean
        w2 = w2(:) - mean(w2(:));
             
        % compute displacement to current skeleton pixel of skel2, as the
        % difference between curvilinear abscissa
        resCorr(l, 1) = S2k(l) - S1pix(k);
        
        % compute image correlation between the two thumbnails.
        resCorr(l, 2) = sum(w1 .* w2) / sqrt(sum(w1 .* w1) * sum(w2 .* w2));
    end
			
    % find the index of maximum correlation by sorting the resCorr array
    resCorr = sortrows(resCorr, 1);
    [corrMax, indMax] = max(resCorr(:, 2)); %#ok<ASGLU>
    
    % increment result array
    a = a + 1;
    E(a, 1) = S1pix(k);
    E(a, 2) = resCorr(indMax,1);
end

% keep and sort relevant results
E = E(1:a, :);
E = sortrows(E, 1);
