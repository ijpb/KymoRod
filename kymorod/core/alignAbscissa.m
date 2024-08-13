function [S, dec] = alignAbscissa(S, A)
%ALIGNABSCISSA Align the arrays of curvilinear abscissa based on radius
%
%   [S, dec] = alignAbscissa(S, A)
%
%   S   the cell array of curvilinear abscissa 
%   A   the cell array of radius
%
%   S   cell array containing the new curvilinear abscissa of each curve
%       after alignment
%   DEC shift between the two curvilinear abscissa
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16: Add comments about the file

% number of points for resampling
nx = 2000;

% allocate array for storing shift in indices
dec = zeros(length(S), 1);

% keep the min of all curvilinear abscissa
Smin = zeros(length(S), 1);

% compare each signal with the previous one
for k = 2:length(S)
    fprintf('.');
	% total curvilinear length of each curve
    L0 = S{k-1}(end) - S{k-1}(1);
    L1 = S{k}(end);
	
	% length ratio between curves
    DL = L1 / L0;
    
	% C is the resampling of smaller curve, with nx points
	% B is resampling of longest curve, with more points, but similar spacing
	% DS is the spacing, the same for both curves
	% DL is the length ratio (current over previous)
	% DL2 is the number of additional points for largest signal
    if DL > 1
		% case of second curve with larger length
        C = resampleFunction(S{k-1}-S{k-1}(1), A{k-1}, nx);
        B = resampleFunction(S{k}, A{k}, nx * DL);
        DL2 = round(nx * (DL-1));
        DS = -(S{k-1}(end) - S{k-1}(1)) / nx;
        
    else
		% case of second curve with smaller length
        DL = 1 / DL;
        B = resampleFunction(S{k-1}-S{k-1}(1), A{k-1}, nx * DL);
        C = resampleFunction(S{k}, A{k}, nx);
        DL2 = round(nx * (DL-1));
        DS = S{k}(end) / nx;
    end
	
    if DL2 < 2
		% in case of signals with comparable lengths, shift equals zero
        dec(k-1) = 0;
    else
		% cross correlation of the two resampled signals
        Corr = zeros(DL2-1, 2);
		for j = 1:DL2-1
			Corr(j, 1) = DS * j;
			Corr(j, 2) = corr2(B(j:end-DL2+j-1), C);
		end
		
		% find a correlation peak
        indPeak = find(Corr(:,2) == max(Corr(:,2)));
        if ~isempty(indPeak)
            dec(k-1) = Corr(indPeak, 1);
        else
            dec(k-1) = 0;
        end
    end
 
	% shift origin of curvilinear abscissa
    S{k} = S{k} + dec(k-1) + S{k-1}(1);
	
	% also keep the global minimum over all curvilinear abscissa
    Smin(k) = S{k}(1);
end
fprintf('\n');

% keep global origin
Sm = min(Smin);

% shift all origins, such that smaller origin is zero
for k = 1:length(S)
   S{k} = S{k} - Sm; 
end
