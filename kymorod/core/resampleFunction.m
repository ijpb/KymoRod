function Ax = resampleFunction(S, A, nx)
% RESAMPL resample a parametric function with a given number of points
% 
%   Ax = resampleFunction(S, A, nx)
%
%   S 	reference positions of the function (n-by-1 array)
%   A 	the function values (n-by-1 array)
%   nx  number of points of the new array (scalar)
%
%   Ax is the new curvilinear abscissa which is resampled using linear
%   interpolation 
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

% curvilinear length of the curve
L = Smax - Smin;

% average length increment between each position in resampled function
DL = L / nx;

% number of positions to interpolate
nPos = round((Smax - Smin) / DL);

% allocate memory
Ax = zeros(nPos, 1);

% for j = 1+round(Smin/DL):round(Smax/DL)
for j = 1:nPos
    X = j * DL;
    
    % index and value of x reference before current position
    ind0 = find(S < X, 1, 'last');
    if isempty(ind0)
        ind0 = 1;
    end
    S0 = S(ind0);
    
    % index and value of x reference after current position
    ind1 = find(S > X, 1, 'first');
    if isempty(ind1)
        ind1 = length(S);
    end
    S1 = S(ind1);
    
    % linear interpolation of function value
    Ax(j) = (A(ind1) * (X - S1) - A(ind0) * (X - S0)) / (S1 - S0);
    
end
