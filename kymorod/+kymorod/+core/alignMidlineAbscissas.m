function S = alignMidlineAbscissas(analysis)
%ALIGNMIDLINEABSCISSAS Compute aligned abscissas from a set of midlines.
%
%   output = alignMidlineAbscissas(input)
%
%   Example
%   alignMidlineAbscissas
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-20,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

% number of images
nFrames = frameCount(analysis);

% allocate memory for data
S = cell(nFrames, 1);
R = cell(nFrames, 1);

% retrieve (calibrated) abscissa and radius from each midline
calib = analysis.InputImages.Calibration;
for i = 1:nFrames
    midline = analysis.Midlines{i};
    S{i} = midline.Abscissas * calib.PixelSize / 1000;
    R{i} = midline.Radiusses;
end

% number of points for resampling
nx = 2000;


% allocate array for storing shift in indices
shifts = zeros(nFrames, 1);

% keep the min of all curvilinear abscissa
Smin = zeros(nFrames, 1);

% compare each signal with the previous one
for k = 2:nFrames
    fprintf('.');

	% total curvilinear length of each curve
    L0 = S{k-1}(end) - S{k-1}(1);
    L1 = S{k}(end);
	
	% R1 is the resampling of the smallest curve, with nx points
	% R2 is resampling of longest curve, with same spacing and more points
	% DS is the shift to apply to abscissas
	% DL is the length ratio (current over previous)
	% DL2 is the number of additional points for largest signal
    if L1 > L0
		% case of second curve with largest length
        S1 = S{k-1}-S{k-1}(1);
        S1new = linspace(S1(1), S1(end), nx);
        R1 = kymorod.core.signal.resampleFunction(S1, R{k-1}, S1new);
        S2 = S{k};
        S2new = linspace(S2(1), S2(end), round(nx * L1 / L0));
        R2 = kymorod.core.signal.resampleFunction(S2, R{k}, S2new);
        deltaS = -S1(end) / nx;
        
    else
		% case of second curve with smallest length
        S1 = S{k};
        S1new = linspace(S1(1), S1(end), nx);
        R1 = kymorod.core.signal.resampleFunction(S1, R{k}, S1new);
        S2 = S{k-1}-S{k-1}(1);
        S2new = linspace(S2(1), S2(end), round(nx * L0 / L1));
        R2 = kymorod.core.signal.resampleFunction(S2, R{k-1}, S2new);
        deltaS = S1(end) / nx;
    end
	
    % number of shifts to test for correlation
    nShifts = length(R2) - length(R1);

    % identify the shift that best align the two signals
    shifts(k) = 0;
    if nShifts > 1
		% compute cross correlation of the two resampled signals
        resCorr = zeros(nShifts-1, 2);
		for j = 1:nShifts-1
			resCorr(j, 1) = deltaS * j;
			resCorr(j, 2) = corr2(R2(j:end-nShifts+j-1), R1);
		end
		
		% find peak in correlation curve
        [~, indMax] = max(resCorr(:,2));
        if ~isempty(indMax)
            shifts(k) = resCorr(indMax, 1);
        end
    end
 
	% shift the origin of curvilinear abscissas
    S{k} = S{k} + shifts(k) + S{k-1}(1);
	
	% also keep the global minimum over all curvilinear abscissa
    Smin(k) = S{k}(1);
end
fprintf('\n');

% keep global origin
Sm = min(Smin);

% shift all origins, such that smallest origin is zero
for k = 1:nFrames
   S{k} = S{k} - Sm; 
end
