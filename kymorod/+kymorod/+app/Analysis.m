classdef Analysis < handle
% Container for data of a Kymorod analysis.
%
%   Class Analysis
%
%   Example
%   Analysis
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
    % The set of parameters that specifies the analysis, as an instance of
    % the Parameters class.
    Parameters;

    % The input images for segmentation, as an instance of TimeLapseImage.
    InputImages;

    % The list of threshold values used to segment images.
    ThresholdValues;
    
    % the list of threshold values computed automatically, without
    % manual correction.
    InitialThresholdValues = [];

    % The list of contours, one polygon by cell, in pixel units.
    Contours = {};

    % The longest path in skeleton for each image, as a cell array of
    % kymorod.data.Midline instances, in pixel coordinates.
    Midlines = {};

    % The curvilinear abscissa after alignment procedure, as a cell array.
    AlignedAbscissas = {};

    % The displacement of each point to the next similar point.
    % Given as a cell array, each cell containing a N-by-2 numeric array,
    % the first column coresponding to the curvilinear abscissa.
    Displacements;

    % The displacement after smoothing and resampling
    % Given as a cell array, each cell containing a N-by-2 numeric array.
    FilteredDisplacements = {};
    
    % Elongation, computed by derivation of filtered displacement.
    Elongations;

end % end properties


%% Constructor
methods
    function obj = Analysis(varargin)
        % Constructor for Analysis class.
        obj.Parameters = kymorod.app.Parameters;
        obj.InputImages = kymorod.data.TimeLapseImage;
    end

end % end constructors



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
        
        str = struct('Type', 'kymorod.app.Analysis');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            
            if strcmpi(name, 'Parameters')
                str.Parameters = toStruct(obj.Parameters);
            elseif strcmpi(name, 'InputImages')
                str.InputImages = toStruct(obj.InputImages);
            % elseif strcmpi(name, 'DisplacementImages') && ~isempty(obj.(name))
            %     str.DisplacementImages = toStruct(obj.DisplacementImages);
            % elseif strcmpi(name, 'ProcessingStep')
            %     str.ProcessingStep = char(obj.ProcessingStep);
            % elseif isa(obj.(name), 'kr.app.DisplayStyle')
            %     str.(name) = toStruct(obj.(name));
            else
                str.(name) = obj.(name);
            end
        end
    end
end

methods (Static)
    function style = read(fileName)
        % Reads information from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the jsonlab library');
        end
        style = kymorod.app.Analysis.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        obj = kymorod.app.Analysis();
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            if strcmpi(name, 'Type')
                continue;
            elseif strcmpi(name, 'Parameters')
                obj.Parameters = kymorod.app.Parameters.fromStruct(str.Parameters);
            elseif strcmpi(name, 'InputImages')
                obj.InputImages = kymorod.data.TimeLapseImage.fromStruct(str.InputImages);
            % elseif strcmpi(name, 'DisplacementImages')
            %     if ~isempty(str.DisplacementImages)
            %         obj.DisplacementImages = kr.app.TimeLapseImage.fromStruct(str.DisplacementImages);
            %     end
            % elseif strcmpi(name, 'ProcessingStep')
            %     obj.ProcessingStep = kr.app.ProcessingStep.parse(str.ProcessingStep);
            % elseif isstruct(str.(name))
            %     field = str.(name);
            %     if ~isfield(field, 'Type')
            %         error('Can not parse structures without "Type" field');
            %     end
            %     if strcmp(field.Type, 'kr.app.DisplayStyle')
            %         obj.(name) = kr.app.DisplayStyle.fromStruct(field);
            %     else
            %         error('Uanble to parse structure with type: %s', field.Type);
            %     end
            else
                obj.(name) = str.(name);
            end
        end
    end
end

end % end classdef

