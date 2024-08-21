function displf = filterDisplacements(displ, LX, LY, dx)
% Apply kernel smoothing filters to displacement data.
%
% Usage:
% DISPLF = filterDisplacements(DISPL, LX, LY, DX)
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
%   DISPLF: a N-by-2 numeric array containing in first column the values of
%   curvilinear abscissa after resampling, and in second column the values
%   of displacement after resampling and filtering.
%

% extract curvilinear abscissa and displacement arrays
S = displ(:,1);
D = displ(:,2);
nDispl = size(displ, 1);

% compute H
H = zeros(nDispl, 1);
for i = 1:nDispl
    kernel = exp(-((S-S(i)).^2) / (2*LX^2));
    H(i) = sum(kernel .* exp(-((D-D(i)).^2)/(2*LY^2))) / sum(kernel);
end

% keep only "valid" values
D2 = displ(H > 0.6, :);

% resample the axis of curvilinear abscissas
X = (S(1):dx:S(end))';

% Compute new displacement values using spatial smoothing in new basis
Y = zeros(length(X), 1);
for i = 1:length(X)
    kernel = exp(-(( D2(:,1) - X(i) ).^2) / (2*LX^2));
    Y(i) = sum(D2(:,2) .* kernel) / sum(kernel);
end

% concatenate results
displf = [X Y];
