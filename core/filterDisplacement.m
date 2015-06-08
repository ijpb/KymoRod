function Eab = filterDisplacement(E)
% FILTERDISPLACEMENT Smooth the curve and remove errors using kernel smoothers
%
%   Eab = filterDisplacement(E)
%   (rewritten from 'aberrant3')
%
%   E  a N-by-2 array containing the curvilinear abscissa and the
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


%% Global settings

% neighborhood along x position
LX = .1;

% difference in values
LY = 1e-2;

% discretization step
dx = 5e-3;


%% Pre-processing

% shifts curvilinear abscissa to start at zero
Smin = E(1,1);
E(:,1) = E(:,1) - Smin;

%% Curve smoothing

% apply curve smoothing
[X, Y] = smoothAndFilterDisplacement(E, LX, LY, dx);
if any(size(X) ~= size(Y))
    warning('arrays X and Y do not have same size...');
end


%% Post-processing

% add initial curvilinear abscissa
Eab = [X + Smin, Y];

% 
%if length(Eab(:,2))>60
%    Eab(:,2)=moving_average(Eab(:,2),30);
%end


