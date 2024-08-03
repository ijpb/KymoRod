classdef Calibration < handle
% Calibration of a time-lapse image.
%
%   Class Calibration
%
%   Example
%   Calibration
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-06-01,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.


%% Properties
properties
    % The spatial calibration of images. Default is 1.0.
    PixelSize = 1.0;
    
    % The coordinates of the upper-left pixel. Default is [1 1].
    PixelOrigin = [1 1];

    % The unit for the spatial calibration of images. Default is 'pixel'.
    PixelSizeUnit = 'pixel';
    
    % The time step beween two images. Default is 1.0.
    TimeInterval = 1.0;
    
    % The time associated to first frame. Default is 0.0.
    TimeOrigin = 0.0;
    
    % The unit name for time interval. Default value is 'frame'.
    TimeIntervalUnit = 'frame';
    
end % end properties


%% Constructor
methods
    function obj = Calibration(varargin)
        % Constructor for Calibration class.
        % 
        % Does nothing.
    end

end % end constructors


%% Methods
methods
    function coord = indexToPoint(obj, index)
        % Convert pixel coordinates to physical coordinates.
        %
        % COORD = indexToPoint(OBJ, INDEX);
        %
        % INDEX is given as [X Y]. Both COORD and INDEX are given in
        % floating point and no rounding is performed. 
        %
        coord = bsxfun(@plus, (index - 1) * obj.PixelSize, obj.PixelOrigin);
    end

    function index = pointToIndex(obj, coord)
        % Convert physical coordinates to pixel coordinates.
        %
        % INDEX = pointToIndex(OBJ, COORD);
        %
        % COORD is given as [X Y]. Both COORD and INDEX are given in
        % floating point and no rounding is performed. 
        %
        index = (bsxfun(@minus, coord, obj.PixelOrigin) / obj.PixelSize) + 1;
    end
    
    function time = indexToTime(obj, index)
        % Convert frame index to time from beginning.
        %
        % TIME = indexToTime(OBJ, INDEX);
        %
        time = (index - 1) * obj.TimeInterval + obj.TimeOrigin;
    end

    function index = timeToIndex(obj, time)
        % Convert time to frame index.
        %
        % FRM = pointToIndex(OBJ, TIME);
        %
        index = (time - obj.TimeOrigin) / obj.TimeInterval + 1;
    end
    
end % end methods


%% Serialization methods
methods
    function write(obj, fileName, varargin)
        % Writes object instance into a JSON file.
        % Requires implementation of the "toStruct" method.
        if exist('savejson', 'file') == 0
            error('Requires the jsonlab library');
        end
        savejson('', toStruct(obj), 'FileName', fileName, varargin{:});
    end
    
    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization.
        
        str = struct('Type', 'kymorod.data.Calibration');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            str.(name) = obj.(name);
        end
    end
end

methods (Static)
    function calib = read(fileName)
        % Reads information from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the jsonlab library');
        end
        calib = kymorod.data.Calibration.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        obj = kymorod.data.Calibration();
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            if strcmp(name, 'Type')
                continue;
            end
            obj.(name) = str.(name);
        end
    end
end

end % end classdef

