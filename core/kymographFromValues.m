function kymo = kymographFromValues(S, A, nPoints)
%KYMOGRAPHFROMVALUES Compute kymograph from a cell array of values
%
%   KYMO = kymographFromValues(SList, VList, NPoints)
%   Computes a kymograph from the a of values associated with a list of
%   curvilinear abscissa.
%
%   Input:
%   * SList: the N-by-1 cell array containing the curvilinear abscissa for
%       each signal
%   * VList: the N-by-1 cell array containing the signal values for each
%       frame/image
%   * NPoints: the number of points used for resampling each signal.
%
%   Output:
%   KYMO: a NPoints-by-N array of doubles, containing NaN for undefined
%       space-time positions.
%
%   Example
%   kymographFromValues
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-03-16,    using Matlab 9.3.0.713579 (R2017b)
% Copyright 2018 INRA - Cepia Software Platform.

% rewritten from reconstruct_Elg2

% number of signals, or frames
nSignals = length(A);

% keep min and max abscissa
Smin = zeros(nSignals, 1);
Smax = zeros(nSignals, 1);
for k = 1:nSignals
    Smin(k,1) = S{k}(1);
    Smax(k,1) = S{k}(end);
end

% the largest abscissa
L = max(Smax);

% discretisation step of curvilinear abscissa
DL = L / nPoints;

% allocate memory for result image
kymo = NaN * ones(nPoints, nSignals);

% iterate on frames
for k = 1:nSignals
    
    % sample NPoints points on the curvilinear abscissa
    for j = 1+round(Smin(k)/DL):round(Smax(k)/DL)
        % convert to curvilinear abscissa
        Sj = j * DL;
        
        % index of first point
        ind0 = find(S{k} < Sj, 1, 'last');
        if isempty(ind0)
            ind0 = 1;
        end
        
        % index of last point
        ind1 = find(S{k} > Sj, 1, 'first');
        if isempty(ind1)
            ind1 = length(S{k});
        end
        
        % curvilinear abscissa for first and last points
        S0 = S{k}(ind0);
        S1 = S{k}(ind1);
        
        % linear interpolation of the signal values around Sj
        kymo(j, k) = (A{k}(ind0)*(Sj-S0) + A{k}(ind1)*(S1-Sj)) / (S1-S0);
    end
end


