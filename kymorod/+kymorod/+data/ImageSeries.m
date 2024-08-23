classdef ImageSeries < handle
% Abstract class for a series of images.
%
%   Class ImageSeries
%
%   Example
%   ImageSeries
%
%   See also
%     SelectedFilesImageSeries

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-02,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Constructor
methods
    function obj = ImageSeries(varargin)
        % Constructor for ImageSeries class.
    end

end % end constructors


%% Methods
methods (Abstract)
    % Return the number of images within the series.
    n = imageCount(obj);
    % Retrieve an image from its index.
    img = getImage(obj, index);

    % Duplicate this object by copying its state.
    series = clone(obj);
end % end methods

end % end classdef

