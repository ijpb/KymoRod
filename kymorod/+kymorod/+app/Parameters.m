classdef Parameters < handle
% The set of parameters used to run an analysis.
%
%   Class Parameters
%
%   Example
%   Parameters
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-04,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    % The name of the smoothing method to apply on images before applying
    % segmentation.
    ImageSmoothingMethodName = 'BoxFilter';

    % The radius of the smoothing filter applied on gray scale image
    % before segmentation
    ImageSmoothingRadius = 2;

    % The stategy for setting up the threshold method on each image
    % Can be one of {'Auto'}, 'Manual'.
    ThresholdStrategy = 'Auto';

    % The method for computing threshold on each image
    % (renamed from 'thresholdMethod')
    % Can be one of {'MaxEntropy'}, 'Otsu'.
    AutoThresholdMethod = 'MaxEntropy';

    % The threshold value for manual threshold
    ManualThresholdValue = 50;

    % The length of window for smoothing coutours. Default value is 20.
    ContourSmoothingSize = 20;

    % location of the first point of the skeleton.
    % Can be one of 'bottom' (default), 'top', 'left', 'right'.
    SkeletonOrigin = 'Bottom';

    % The size of the window for computing curvature, in vertex number.
    % Default is 10.
    CurvatureWindowSize = 10;

    % The number of points used on space axis to compute kymograph.
    % Default is 500.
    KymographAbscissaSize = 500;

    % The channel used for computing displacements (for color images).
    DisplacementImageChannel = 'red';

    % Frame offset for computing displacements. Default value is 2.
    DisplacementStep = 2;

    % Size of first correlation window (in pixels). Default value is 20.
    MatchingWindowRadius = 20;

    % Smooth displacement curve giving more weight to spatially closer values.
    % Default value is 0.1.
    DisplacementSpatialSmoothing = .1;

    % Smooth displacement curve giving more weight to similar values.
    % Default value is 1e-2.
    DisplacementValueSmoothing = 1e-2;

    % Discretisation step for computing filtered displacements.
    % Default value is 5e-3.
    DisplacementResampling = 5e-3;

    ElongationDerivationRadius = 20;

end % end properties


%% Constructor
methods
    function obj = Parameters(varargin)
        % Constructor for Parameters class.

    end

end % end constructors

%% Serialization methods
methods
    function write(obj, fileName, varargin)
        % Writes representation into a JSON file.
        % Requires implementation of the "toStruct" method.
        if exist('savejson', 'file') == 0
            error('Requires the jsonlab library');
        end
        savejson('', toStruct(obj), 'FileName', fileName, varargin{:});
    end
    
    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization.
        
        str = struct('Type', 'kymorod.app.Parameters');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            value = obj.(name);
            % if strcmpi(name, 'ImageSmoothingMethod')
            %     str.ImageSmoothingMethod = char(value);
            % elseif strcmpi(name, 'ThresholdMethod')
            %     str.ThresholdMethod = char(value);
            % elseif strcmpi(name, 'FirstPointLocation')
            %     str.FirstPointLocation = char(value);
            % else
                str.(name) = value;
            % end
        end
    end
end

methods (Static)
    function params = read(fileName)
        % Reads information from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the jsonlab library');
        end
        params = kymorod.app.Parameters.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        obj = kr.app.Parameters();
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            value = str.(name);
            if strcmpi(name, 'Type')
                continue;
            % elseif strcmpi(name, 'ImageSmoothingMethod')
            %     obj.ImageSmoothingMethod = kr.app.enums.ImageSmoothingMethods.fromName(value);
            % elseif strcmpi(name, 'ThresholdMethod')
            %     obj.ThresholdMethod = kr.app.enums.ThresholdMethods.fromName(value);
            % elseif strcmpi(name, 'FirstPointLocation')
            %     obj.FirstPointLocation = kr.app.enums.MidlineFirstPointLocations.fromName(value);
            else
                obj.(name) = value;
            end
        end
    end
end


end % end classdef

