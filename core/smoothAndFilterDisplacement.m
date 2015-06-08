function [X, Y] = smoothAndFilterDisplacement(E, LX, LY, dx)
% Apply kernel smoothing filters to displacement array
%
% Usage:
% [X, Y] = smoothAndFilterDisplacement(E, LX, LY, dx)
% X and Y are expected to be column vectors with same size.
%

% extract curvilinear abscissa and displacement arrays
S = E(:,1);
D = E(:,2);

% number of expected points ?
nx = (max(S) - min(S)) / dx;

% compute H
H = zeros(length(S), 1);
for k = 1:length(E)
    H(k) = sum(exp(-((S-S(k)).^2)/(2*LX^2)) .* exp(-((D-D(k)).^2)/(2*LY^2))) / sum(exp(-((S-S(k)).^2)/(2*LX^2)));
%    D(k) = sum(exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2)).*exp(-((E(:,2)-E(k,2)).^2)./(2.*LY.^2)))./sum(exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2)));   
end

% remove "outliers"
E2 = E(H>.6, :);

% define new x axis, linearly spaced between min and max values
X = (0:S(end)/nx:S(end))';

% Compute new value for Y array (the displacement)
Y = zeros(length(X), 1);
for k = 1:length(X)  
    Y(k) = sum(E2(:,2).*exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2)))./sum(exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2)));   
end
 

