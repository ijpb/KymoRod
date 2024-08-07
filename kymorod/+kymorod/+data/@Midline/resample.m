function res = resample(obj, step)
% Resample midline parametrized with abscissa.
%
%   CURVE2 = resample(CURVE, STEP)
%   STEP is the step in curvilinear abscissa.
%
%   Example
%   resampleMidline
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-12,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% compute the number of points for sampling the polyline
% (equal to the number of segments plus one)
S = obj.Abscissas;
Smin = S(1);
Smax = S(end);
n = round((Smax - Smin) / step) + 1;

% distribute N points equally spaced
S2 = linspace(Smin, Smax, n)';

poly2 = zeros(n, 2);
for i = 1:n
    % index of surrounding vertices before and after
    ind0 = find(S <= S2(i), 1, 'last');
    ind1 = find(S >= S2(i), 1, 'first');
    
    if ind0 == ind1
        % get position of a vertex in input polyline
        poly2(i, :) = obj.Coords(ind0, :);
        continue;
    end
    
    % position of surrounding vertices
    pt0 = obj.Coords(ind0, :);
    pt1 = obj.Coords(ind1, :);
    
    % weights associated to each neighbor
    l0 = S2(i) - S(ind0);
    l1 = S(ind1) - S2(i);
    
    % linear interpolation of neighbor positions
    if (l0 + l1) > Smax * 1e-12
        poly2(i, :) = (pt0 * l1 + pt1 * l0) / (l0 + l1);
    else
        % if neighbors are too close, do not use interpolation
        poly2(i, :) = pt0;
    end
end

% create result curve
res = kymorod.data.Midline(poly2);
res.Abscissas = S2;

% if radius is defined, apply resampling
if ~isempty(obj.Radiusses)
    res.Radiusses = kymorod.core.signal.resampleFunction(S, obj.Radiusses, S2);
end
