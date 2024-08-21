function [X, Y] = filterDisplacements(displ, LX, LY, dx)
% Apply kernel smoothing filters to displacement data.
%
% Usage:
% [X, Y] = filterDisplacements(DISPL, LX, LY, DX)
%
% Inputs:
%   DISPL: displacement data, as N-by-2 numeric array containing curvilinear
%       abscissa in first column and displacements in second column.
%   LX: value of smoothing in the spatial domain
%   LY: value of smoothing in the value domain
%   DX: resampling step of curvilinear abscissa for computing filtered
%       result
%
% Outputs:
%   X:  value of curvilinear abscissa after resampling
%   Y:  displacement values after resampling and filtering
%   X and Y are expected to be column vectors with same size.
%

% extract curvilinear abscissa and displacement arrays
S = displ(:,1);
D = displ(:,2);
nDispl = size(displ, 1);

% compute H
H = zeros(nDispl, 1);
for k = 1:nDispl
    kernel = exp(-((S-S(k)).^2)/(2*LX^2));
    H(k) = sum(kernel .* exp(-((D-D(k)).^2)/(2*LY^2))) / sum(kernel);
end

% keep only "valid" values
E2 = displ(H > 0.6, :);

% define new x axis, linearly spaced between min and max abscissas
% number of expected points ?
% nx = (max(S) - min(S)) / dx;
% X = (0:S(end)/nx:S(end))';
X = (S(1):dx:S(end))';

% Compute new displacement values
Y = zeros(length(X), 1);
for k = 1:length(X)
    kernel = exp(-(( E2(:,1) - X(k) ).^2) / (2*LX^2));
    Y(k) = sum(E2(:,2) .* kernel) / sum(kernel);
end

