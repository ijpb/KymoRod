classdef PlotAxis < handle
% One-line description here, please.
%
%   Class PlotAxis
%
%   Example
%   PlotAxis
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-05-29,    using Matlab 24.1.0.2537033 (R2024a)
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    Data;
    Name;
    Unit;
end % end properties


%% Constructor
methods
    function obj = PlotAxis(data, varargin)
        % Constructor for PlotAxis class.

        % copy constructor
        if isa(data, 'kymorod.core.PlotAxis')
            obj.Data = data.Data;
            obj.Name = data.Name;
            obj.Unit = data.Unit;
            return;
        end

        % initialisation constructor
        obj.Data = data;

        while length(varargin) > 1
            pname = varargin{1};
            if strcmpi(pname, 'Name')
                obj.Name = varargin{2};
            elseif strcmpi(pname, 'Unit')
                obj.Unit = varargin{2};
            else
                error('Unknown argument name: %s', pname);
            end
            varargin(1:2) = [];
        end

        if ~isempty(varargin)
            error('Wrong number of input arguments when creating PlotAxis');
        end
    end


end % end constructors


%% Methods
methods
    function label = createLabel(obj)
        if isempty(obj.Unit)
            label = obj.Name;
        else
            label = sprintf('%s [%s]', obj.Name, obj.Unit);
        end
    end
end % end methods

end % end classdef

