function [S, dec] = aligncurv(S, A)
%ALIGNCURV align the curves
%
% [S, dec] = aligncurv(S, A)
% S: the cell array of curvilinear abscissa 
% A: the cell array of radius
%
% S: an array of cell containing the new curvilinear abscissa of each curve
% dec : shift between the two curvilinear abscissa
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

% % ensure abscissa start at zero
% % TODO: necessary ? (it is already the case...)
% for k = 1:length(S)
%    S{k} = S{k} - S{k}(1); 
% end

%parfor_progress(length(S));

% keep the min of all curvilinear abscissa
Smin = zeros(length(S), 1);

% compare each signal with the previous one
for k = 2:length(S)
    
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
        C = resampl(nx, A{k-1}, S{k-1}-S{k-1}(1));
        B = resampl(nx * DL, A{k}, S{k});
        DL2 = round(nx * (DL-1));
        DS = -(S{k-1}(end) - S{k-1}(1)) / nx;
    else
		% case of second curve with smaller length
        DL = 1./DL;
        B = resampl(nx.*DL, A{k-1}, S{k-1}-S{k-1}(1));
        C = resampl(nx, A{k}, S{k});
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
    % parfor_progress;
end
%parfor_progress(0);

% keep global origin
Sm = min(Smin);

% shift all origins, such that smaller origin is zero
for k = 1:length(S)
   S{k} = S{k} - Sm; 
end
