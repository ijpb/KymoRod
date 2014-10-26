function CT = cont(pic, thres)
% CONT Compute the contour CT on an image PIC with the threshold defined by THRES
%
% CT = cont(pic, thres)
% pic: 		a grey level image
% thres: 	the treshold, manually defined
%
% Return the contour C of the largest connected component, given by a N-by-2
% array containing vertex coordinates.
% The contours touching the border of the image are not returned.
% 

% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% extract image size
[s1, s2] = size(pic);
Sm = max(size(pic));

% ????
if thres < Sm
	pic = double(pic) + Sm;
	thres = thres + Sm;
end

% All the contours C are computed
C = contour(pic, [thres thres]);

% find indices of contour data
u = find(C(1,:) == thres);

% initialize vertex indices in coordinate array
Cmin = 0; 
Cmax = 0;

% initialize length of largest contour
lmax = 0;
    
% iterate over the contour set to compute number of vertices of each contour
for j = 2:length(u)
	lt = u(j) - u(j-1);
	if lt > lmax
        Cmin = u(j-1);
        Cmax = u(j);
        lmax = lt;
	end
end

% length of the last contour
if length(u) > 1
	lt = length(C)-u(j);
else
	lt = length(C)-u(1);
	j = 1;
end

% check if the last contour is the largest
if lt > lmax
    Cmin = u(j);
	Cmax = length(C);
	lmax = lt;
end

% initial contour, as a N-by-2 array of vertex coordinates
nu = [C(1,Cmin+1:Cmax-1) ; C(2,Cmin+1:Cmax-1)];

% remove double vertices in contour
CT = cleandouble(nu');
 
% TODO: remove duplicate code!

% If the contour to compute is over the lower and upper border of the image
if min(CT(:,2)) < 2 && max(CT(:,2)) > s1-2
	L = (1:s2).*0;
	pic = [L;pic;L];
	Sm = max(size(pic));
	if thres < Sm
        pic = double(pic) + Sm;
        thres = thres + Sm;
	end
    % All the contours C are computed
	C = contour(pic, [thres thres]);
	u = find(C(1,:) == thres);
    
	% Keep the largest contour
	Cmin = 0;Cmax = 0;lmax = 0;
	for j = 2:length(u)
        lt = u(j) - u(j-1);
		
        if lt > lmax
            Cmin = u(j-1);
            Cmax = u(j);
            lmax = lt;
        end
	end
	
    if length(u) > 1
        lt = length(C) - u(j);
    else
        lt = length(C) - u(1);
        j = 1;
    end
	
    if lt > lmax
        Cmin = u(j);
        Cmax = length(C);
        lmax = lt;
    end
    nu = [C(1,Cmin+1:Cmax-1);C(2,Cmin+1:Cmax-1)];
	
    % The double points of the contour are cleaned
    CT = cleandouble(nu');
    CT(:,2) = CT(:,2)-1;
end
