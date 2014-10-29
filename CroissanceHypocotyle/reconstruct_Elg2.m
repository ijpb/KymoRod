function [Ax] = reconstruct_Elg2(nx, varargin)
%RECONSTRUCT_ELG2 Construct kymograph
%
% C2 = reconstruct_Elg2(nx, C);
% C2 = reconstruct_Elg2(nx, C, Sa);
% Reconstruct an image from a list of signals
%
% nx : number of points on which we resample the skeleton
% varargin{1} : data who become a kymograph
% if the data is a vector at two dimensions use only two arguments
% Else if it's just a vector at on dimensions, you must use a third argument, the curvilinear abscissa 
%
%
%
% Return : the image of kymograph (opening with imagesc())
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file


if length(varargin) == 1
    signalList = varargin{1};
    nSignals = length(signalList);
    S = cell(nSignals, 1);
    A = cell(nSignals, 1);

    for k = 1:nSignals;
        signal = signalList{k};
        if ~isempty(signal)
            S{k} = signal(:, 1);
            A{k} = signal(:, 2);
        else
            S{k} = 0;
            A{k} = 0;
        end
    end
    
elseif length(varargin) == 2
    % first input is signal list, second input is list of abscissa
    A = varargin{1};
    S = varargin{2};
end

% number of signals, of frames
nSignals = length(A);

% keep min and max abscissa
Smin = zeros(nSignals, 1);
Smax = zeros(nSignals, 1);
for k = 1:nSignals;
    Smin(k,1) = S{k}(1);
    Smax(k,1) = S{k}(end);
end


L = max(Smax);
DL = L ./ nx;

% allocate memory for result image
Ax = NaN * ones(nx, nSignals);

% iterate on frames
for k = 1:nSignals
    
    % process only signals with enough data
    if length(A{k}) > 10
        
        % distribute some points
        for j = 1+round(Smin(k)./DL):round(Smax(k)./DL)            
            % convert to curvilinear abscissa
            X = j * DL;
            posmin = find(S{k} < X, 1, 'last');
            if isempty(posmin)
                posmin = 1;
            end
            posmax = find(S{k} > X, 1, 'first');
            if isempty(posmax)
                posmax = length(S{k});
            end
            
            % linear interpolation ?
            Ax(j, k) = ...
                -(A{k}(posmax).*(X-S{k}(posmax))-A{k}(posmin).*(X-S{k}(posmin)))...
                ./(S{k}(posmax)-S{k}(posmin));
            
        end
    end
end
