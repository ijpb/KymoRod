function Eab = filterDisplacement(E2)
% FILTERDISPLACEMENT Smooth the curve and remove errors using kernel smoothers
%
%   Eab = filterDisplacement(E2)
%   (rewritten from 'aberrant3')
%
%   E2  a N-by-2 array containing the curvilinear abscissa and the
%       displacement computed for a series of points
%   
%   Eab a N-by-2 array containing the curvilinear abscissa and the
%       displacement after applying smoothing and removal of outliers.
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% allocate memory for result
E = E2;

% ?
LX = .1;
LY = 1e-2;

% shifts curve to start at zero
Smin = E2(1,1);
E(:,1) = E2(:,1) - Smin;

% apply curve smoothing
[X, Y]= smoothAndFilterDisplacement(E, LX, LY, 5e-3);

% add initial curvilinear abscissa
Eab(:,1) = X + Smin;
Eab(:,2) = Y;

%if length(Eab(:,2))>60
%    Eab(:,2)=moving_average(Eab(:,2),30);
%end


