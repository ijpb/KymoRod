classdef Midline < handle
% The midline of the organ.
%
%   Class Midline
%
%   Example
%   Midline
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-12-31,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.


%% Properties
properties
    % The coordinates of the vertices, as a N-by-2 array.
    Coords;
    
    % The curvilinear abscissa of each vertex, as a N-by-1 array.
    Abscissas = [];
    
    % A radius associated to each vertex, as a N-by-1 array.
    Radiusses = [];
    
    % A curvature associated to each vertex, as a N-by-1 array.
    Curvatures = [];
end % end properties


%% Constructor
methods
    function obj = Midline(coords, varargin)
        % Constructor for Midline class.
        
        % check validity of coords
        if size(coords, 2) ~= 2
            error('Wrong number of dimensions for Coords argument');
        end        
        obj.Coords = coords;
        
        % pre-compute default curvilinear abscissa
        obj.Abscissas = [0 ; cumsum(hypot(diff(obj.Coords(:,1)), diff(obj.Coords(:,2))))];

        % process optional curvilinear abscissa
        if ~isempty(varargin)
            var1 = varargin{1};
            if isnumeric(var1)
                obj.Abscissas = var1(:);
                varargin(1) = [];
            end
        end
        
        if ~isempty(varargin)
            error('Can not process additional argument');
        end
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
        
        str = struct('Type', 'kymorod.data.Midline');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            str.(name) = obj.(name);
        end
    end
end

methods (Static)
    function style = read(fileName)
        % Reads information from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the jsonlab library');
        end
        style = kymorod.data.Midline.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        coords = str.Coords;
        obj = kymorod.data.Midline(coords);
        
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            if strcmpi(name, 'Type')
                continue;
            else
                obj.(name) = str.(name);
            end
        end
    end
end


end % end classdef

