function E = computeDisplacementPx(SQ1, SQ2, S1, S2, pic1, pic2, ws)
%COMPUTEDISPLACEMENTPX Compute elongation between two frames in pixel coordinates
% 
% E = computeDisplacementPx(SQ1, SQ2, S1, S2, pic1, pic2, ws)
% (rewritten from elong5)
%
% SQ1: 		skeleton number one
% SQ2: 		skeleton number two
% S1: 		curvilinear abscissa number one
% S2: 		curvilinear abscissa number two
% Pic1: 	image number one
% Pic2: 	image number two
% ws: 		size of the correlation window
%
% E: a N-by-2 array, containing for each vertex the curvilinear abscissa
% and the displacement (difference in curvilinear abscissa)
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% % flag for displaying evolution of computation or not
% disp = 0;

dim = size(pic1);

%L=20;
%L=0.5;
L = 0.25; %2.*ws./scale;
a = 0;

% on prend les points de l'image pour lesquels l'abscisse curviligne passe,
% correspondant aux points ou passent le squelette.
[x1, y1, S1bis] = snapFunctionToPixels(pic1, SQ1, S1);
[x2a, y2a, S2bis] = snapFunctionToPixels(pic2, SQ2, S2);

% allocate memory for result
E = zeros(length(x1), 2);

% on applique la PIV sur tous les points ou passent le squelette
for k = 1:length(x1)
	% image indices of current point
    i = y1(k);
    j = x1(k);
   
    % process only skeleton points that are not too close from border
    if i <= ws || j <= ws || (dim(1)-i) <= ws || (dim(2)-j) <= ws
        continue;
    end
    
    % get small image around current point of first skeleton
    w1 = double(pic1(i-ws:i+ws, j-ws:j+ws));
    
    % compute PIV only if variability in window is sufficient
    V = std2(w1);
    if V <= 1
        continue;
    end
        
    % transform to vector, and remove mean
    w1 = w1(:) - mean(w1(:));
    
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
        error('Could not find enough points in second contour close to point (%d,%d)', j, i);
    end
    
    % initialze result of image to image correlation
    Corr = zeros(length(x2), 2);
    
    for l = 1:length(x2)
        % indices of positions in second image
        u = y2(l);
        v = x2(l);
        
        % get small image around current point in second skeleton
        w2 = double(pic2(u-ws:u+ws, v-ws:v+ws));
        
        % transform to vector, and remove mean
        w2 = w2(:) - mean(w2(:));
                
        % on peut donc calculer la correlation entre les deux images, on
        % obtient une fonction qui nous donne les valeurs de correlation en
        % fonction de la  difference d'abscisse curviligne entre les deux
        % points (le deplacement).
        Corr(l, 1) = S2k(l) - S1bis(k);
        Corr(l, 2) = sum(w1 .* w2) / sqrt(sum(w1 .* w1) * sum(w2 .* w2));
        
        %sum(sum(( w1 - Ix ) .* (w2 - Iy )))/sqrt(Normx*Normy);
        %if disp==1;clear figure;subplot(2,2,1); imagesc(w1);subplot(2,2,2); imagesc(w2);drawnow; end;
        % 				end
    end
			
    % find the index of maximum correlation by sorting the Corr array
    Corr = sortrows(Corr, 1);
    [Corrmax, Corry] = max(Corr(:, 2)); %#ok<ASGLU>
    
    a = a + 1;
    E(a, 1) = S1bis(k);
    E(a, 2) = Corr(Corry,1);

% 			if disp == 1
% 				subplot(2,2,3);
% 				hold off;
% 				plot(Corr(:,1), Corr(:,2), 'go', Corr(Corry,1), Corr(Corry,2), 'r+'); 
% 				drawnow;
% 			end
% 			
% 			if disp == 1
% 				subplot(2,2,4); hold off;
% 				plot(E(:,1), E(:,2), 'ro'); 
% 				drawnow;
% 			end

% 			clear x2;
% 			clear y2;

end

E = E(1:a, :);
E = sortrows(E, 1);
