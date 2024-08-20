function displ = computeDisplacements(mid1, mid2, img1, img2, radius, maxDeltaS)
%COMPUTEDISPLACEMENTS Compute displacement between two midlines.
%
%   DISPL = computeDisplacements(MID1, MID2, IMG1, IMG2, RADIUS, MAXDELTAS)
%   Compute displacement between two frames, given midlines in each frame,
%   reference image for each frame, size of correlation window, and
%   threshold on the maximal difference in curvilinear abscissa between the
%   two skeletons.
%   Midlines must have coordinates in pixels, and curvilinear abscissas in
%   calibrated units.
%   
%   Input arguments:
%   MID1:      the midline associated to first frame
%   MID2:      the midline associated to second frame
%   IMG1: 	   image of the first frame
%   IMG2: 	   image of the second frame
%   RADIUS:	   radius of the window for computing correlation (in pixels)
%   MAXDELTAS: max difference in curvilinear abscissa (in user unit)
%   Both midline should have coordinates in pixels and curvilinear abscissa
%   in user unit.
%
%   Output arguments:
%   DISPL:  a N-by-2 numeric array, containing curvilinear abscissa and the
%   displacement of a collection of points located on the first midline.
%
%   Example
%   computeDisplacements
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-20,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

% snap midlines to pixels, using default calibration
mid1px = snapToPixels(mid1);
mid2px = snapToPixels(mid2);

% keep only midline vertices that are not too close from border
dim = size(img1);
bounds = [radius+1 dim(2)-radius radius+1 dim(1)-radius];
mid1 = clip(mid1px, bounds);
mid2 = clip(mid2px, bounds);

% allocate memory for result
nv = length(mid1.Abscissas);
displ = NaN * ones(nv, 2);
displ(:,1) = mid1.Abscissas;

% Iterate over vertices of the midline
for k1 = 1:nv
	% image indices of current point
    i1 = mid1.Coords(k1,2);
    j1 = mid1.Coords(k1,1);
   
    % get small sub-image around current point of first midline
    sub1 = double(img1(i1-radius:i1+radius, j1-radius:j1+radius));
    
    % check that variability within sub-image is sufficient
    V = std2(sub1);
    if V < 0.1
        warning(['KymoRod:' mfilename], ...
            'window around point (%d,%d) has not enough variability, try larger window size', j1, i1);
        continue;
    end
        
    % transform to vector, and remove mean
    sub1 = sub1(:) - mean(sub1(:));
    
    % identify positions in second image with similar curvilinear abscissa
    inds = find(abs(mid2.Abscissas - mid1.Abscissas(k1)) < maxDeltaS);

    % check degenerate cases
    if isempty(inds)
        warning(['KymoRod:' mfilename], ...
            'Could not find enough points in second midline close to point (%d,%d),\ntry larger limit in abscissa', j1, i1);
        continue;
    end
    
    % initialize result of image to image correlation
    % first column contains difference in curvilinear coordinate
    % second column contains correlation coefficient
    resCorr = zeros(length(inds), 2);
    
    % iterate over pixels of second midline close enough from current pixel
    for k2 = 1:length(inds)
        % indices of positions in second image
        i2 = mid2.Coords(inds(k2),2);
        j2 = mid2.Coords(inds(k2),1);
        
        % get sub-image around current point in second midline
        sub2 = double(img2(i2-radius:i2+radius, j2-radius:j2+radius));
        
        % transform to vector, and remove mean
        sub2 = sub2(:) - mean(sub2(:));
             
        % compute displacement to current midline pixel of mid2, as the
        % difference between curvilinear abscissa
        resCorr(k2, 1) = mid2.Abscissas(inds(k2)) - mid1.Abscissas(k1);
        
        % compute image correlation between the two thumbnails.
        resCorr(k2, 2) = sum(sub1 .* sub2) / sqrt(sum(sub1.^2) * sum(sub2.^2));
    end
			
    % find the index of maximum correlation by sorting the resCorr array
    resCorr = sortrows(resCorr, 1);
    [corrMax, indMax] = max(resCorr(:, 2)); %#ok<ASGLU>
    
    % update result array
    displ(k1, 2) = resCorr(indMax,1);
end

% retain only valid values
inds = ~isnan(displ(:,2));
displ = displ(inds, :);
