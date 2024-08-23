function val = imEvaluate(img, point, varargin)
% Evaluate image value at given position(s).
%
%   VAL = imEvaluate(IMG, PTS)
%   Evaluates the value within the image grayscale or a color IMG at the
%   position(s) given by PTS. 
%   IMG is an array containing the image
%
%   VAL = imEvaluate(..., METHOD)
%   Specifies the interpolation method to use. The same options as for the
%   'interp2' or 'interp3' functions are available: 'nearest', {'linear'},
%   'spline', 'cubic', or 'makima'. Default is 'linear'.
%
%   VAL = imEvaluate(..., METHOD, EXTRAPVAL)
%   Also specifies the value for pixels outside of the image domain.
%
%   Example
%     % plot profile of a grayscale image
%     img = imread('cameraman.tif');
%     xi = 1:200;
%     yi = 200*ones(1, 200);
%     imshow(img); hold on; plot(xi, yi, '-b');
%     vals = imEvaluate(img, [xi' yi']);
%     figure; plot(vals)
%   
%
%   See also
%     imLineProfile, interp2, interp3, improfile
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2012-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Default values

% use linear interpolation as default
method = 'linear';

% fill background with black
fillValue = 0;


%% Process input arguments

% parse interpolation method
if ~isempty(varargin) && ischar(varargin{1})
    method = varargin{1};
    varargin(1) = [];
end

% use fast interpolation, because images are monotonic
if ischar(method) && method(1) ~= '*'
    method = ['*' method];
end

% parse background value
if ~isempty(varargin)
    fillValue = varargin{1};
end
    

%% Initialisations

% number of values to interpolate
nv = size(point, 1);

% number of image channels
nc = 1;
if ndims(img) > 2 %#ok<ISMAT>
    nc = size(img, 3);
    
    if isscalar(fillValue)
        fillValue = repmat(fillValue, 3, 1);
    end
end

% allocate memory for result
val = zeros(nv, nc);


%% Compute interpolation

% planar case
x = 1:size(img, 2);
y = 1:size(img, 1);

if nc == 1
    % planar grayscale
    val(:) = interp2(x, y, double(img), ...
        point(:, 1), point(:, 2), method, fillValue);
else
    % planar color
    for i = 1:nc
        val(:, i) = interp2(x, y, double(img(:, :, i)), ...
            point(:, 1), point(:, 2), method, fillValue(i));
    end
end


% keep same size for result, but add one dimension for channels
dim = [length(val) nc];

% reshape result to have the same dimension as original point input
val = reshape(val, dim);
