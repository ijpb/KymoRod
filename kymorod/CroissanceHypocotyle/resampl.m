function [Ax] = resampl(nx, A, S)
% RESAMPL resample a parametric function with a given number of points
% 
% Ax = resampl(nx, A, S)
%
% nx: 	number of points of the new signal
% A: 	the radius
% S: 	the curvilinear abscissa 
%
% Ax is the new curvilinear abscissa who is resample by linear interpolation
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% min and max abscissa
Smin = S(1);
Smax = S(end);

% total length of the curve
L = max(Smax);

% length increment between each position
DL = L ./ nx;

% TODO: replace by linspace
nPos = length(1+round(Smin./DL):round(Smax./DL));

% allocate memory
Ax = zeros(nPos, 1);

for j = 1+round(Smin./DL):round(Smax./DL)
    X = j .* DL;
    
    posmin = find(S < X, 1, 'last');
    if isempty(posmin)
        posmin = 1;
    end
    
    posmax = find(S > X, 1, 'first');
    if isempty(posmax)
        posmax = length(S);
    end
    
    Ax(j,1) = ...
        (A(posmax) .* (X-S(posmax)) - A(posmin) .* (X-S(posmin)))...
        ./ (S(posmax) - S(posmin));
    
end
