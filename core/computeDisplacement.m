function E = computeDisplacement(SK1, SK2, S1, S2, pic1, pic2, ws, L)
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
% % flag for displaying evolution of computation or not
 disp = 0;
dim = size(pic1);

% identify in each image the pixels containing a portion of skeleton
[x1, y1, S1bis] = snapFunctionToPixels(pic1, SK1, S1);
[x2a, y2a, S2bis] = snapFunctionToPixels(pic2, SK2, S2);

% allocate memory for result
E = zeros(length(x1), 2);

% counter for number of computed correlations
a = 0;

% apply Particle Image Velocimetry on each point of the skeleton
for k = 1:100:length(x1)
	% image indices of current point
    i = y1(k);
    j = x1(k);
   
    % process only skeleton points that are not too close from border
    if i <= ws || j <= ws || i >= (dim(1)-ws) || j >= (dim(2)-ws)
        continue;
    end
    
    % get small image around current point of first skeleton
    w1a = double(pic1(i-ws:i+ws, j-ws:j+ws));
    
    % compute PIV only if variability in window is sufficient
    V = std2(w1a);
    if V <= 1
        continue;
    end
        
    % transform to vector, and remove mean
    w1 = w1a(:) - mean(w1a(:));
    
    % identify positions in second image with similar curvilinear abscissa
    inds = find( abs(S2bis - S1bis(k)) < L & S2bis > 0);
    x2  = x2a(inds);
    y2  = y2a(inds);
    S2k = S2bis(inds);

    % process only neighbor points that are not too close from border
    inds = (x2 > ws) & (x2 < dim(2)-ws) & (y2 > ws) & (y2 < dim(1)-ws);
    x2 = x2(inds);
    y2 = y2(inds);
    S2k = S2k(inds);
    
    % check degenerate cases
    if isempty(x2)
        error('Could not find enough points in second skeleton close to point (%d,%d)', j, i);
    end
    
    % initialze result of image to image correlation
    Corr = zeros(length(x2), 2);
    
    for l = 1:length(x2)
        % indices of positions in second image
        u = y2(l);
        v = x2(l);
        
        % get small image around current point in second skeleton
        w2a = double(pic2(u-ws:u+ws, v-ws:v+ws));
        
        % transform to vector, and remove mean
        w2 = w2a(:) - mean(w2a(:));
                
        % compute image correlation between the two thumbnails.
        % the result is the correlation value, and the difference in
        % curvilinear abscissa between the two points, which is associated
        % to the displacement
        Corr(l, 1) = S2k(l) - S1bis(k);
        Corr(l, 2) = sum(w1 .* w2) / sqrt(sum(w1 .* w1) * sum(w2 .* w2));
        
        if disp==1;clear figure;subplot(2,2,1); imagesc(w1a);subplot(2,2,2); imagesc(w2a);drawnow; end;
        %
    end
			
    % find the index of maximum correlation by sorting the Corr array
    Corr = sortrows(Corr, 1);
    [Corrmax, Corry] = max(Corr(:, 2)); %#ok<ASGLU>
    
    % increment result array
    a = a + 1;
    E(a, 1) = S1bis(k);
    E(a, 2) = Corr(Corry,1);
    
    
 			if disp == 1
 				subplot(2,2,3);
				hold off;
				plot(Corr(:,1), Corr(:,2), 'go', Corr(Corry,1), Corr(Corry,2), 'r+'); 
 				drawnow;
 			end
 			
 			if disp == 1
 				subplot(2,2,4); hold off;
 				plot(E(:,1), E(:,2), 'ro'); 
 				drawnow;
 			end
end

% keep and sort relevant results
E = E(1:a, :);
E = sortrows(E, 1);
