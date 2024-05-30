classdef Kymograph < handle
% Encapsulate Kymograph data and meta-data.
%
%   Class Kymograph
%
%   Example
%     KG = kymorod.core.Kymograph(DATA);
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
    % The data to display.
    Data;

    DisplayRange = [];

    % A name
    Name = '';

    TimeAxis = [];
    PositionAxis = [];

end % end properties


%% Constructor
methods
    function obj = Kymograph(data, varargin)
        % Constructor for Kymograph class.
        %
        % KG = kymorod.core.Kymograph(DATA);
        %
        obj.Data = data;

        while length(varargin) > 1
            pname = varargin{1};
            if strcmpi(pname, 'Name')
                obj.Name = varargin{2};

            elseif strcmpi(pname, 'TimeAxis')
                if ~isa(varargin{2}, 'kymorod.core.PlotAxis')
                    error('TimeAxis option must be an instance of kymorod.core.PlotAxis');
                end
                obj.TimeAxis = kymorod.core.PlotAxis(varargin{2});

            elseif strcmpi(pname, 'PositionAxis')
                if ~isa(varargin{2}, 'kymorod.core.PlotAxis')
                    error('PositionAxis option must be an instance of kymorod.core.PlotAxis');
                end
                obj.PositionAxis = kymorod.core.PlotAxis(varargin{2});

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
    function varargout = show(varargin)
        % Display the image of this kymograph.

        % parse input arguments
        [ax, varargin] = kymorod.util.parseAxisHandle(varargin{:});
        obj = varargin{1};
        
        % ensure bounds are computed
        validateDisplayRange(obj);

        % retrieve axis data
        xdata = xData(obj);
        ydata = yData(obj);
        
        % display image data
        hIm = imagesc(ax, 'XData', xdata, 'YData', ydata, 'CData', obj.Data);
        set(ax, 'XLim', xdata([1 end]), 'YLim', ydata([1 end]));
        set(ax, 'CLim', obj.DisplayRange);

        if ~isempty(obj.TimeAxis)
            xlabel(ax,  createLabel(obj.TimeAxis), 'Interpreter', 'None');
        end
        if ~isempty(obj.PositionAxis)
            ylabel(ax,  createLabel(obj.PositionAxis), 'Interpreter', 'None');
        end

        if nargout > 0
            varargout = {hIm};
        end
    end

    function xdata = xData(obj)
        % Retrieve numerical data corresponding to time axis (X-axis).
        if isempty(obj.TimeAxis)
            xdata = 1:size(obj.Data, 2);
        else
            xdata = obj.TimeAxis.Data;
        end
    end

    function ydata = yData(obj)
        % Retrieve numerical data corresponding to position axis (Y-axis).
        if isempty(obj.PositionAxis)
            ydata = 1:size(obj.Data, 1);
        else
            ydata = obj.PositionAxis.Data;
        end
    end

    function validateDisplayRange(obj)
        % Make sure DisplayRange is computed.
        if isempty(obj.DisplayRange)
            mini = min(obj.Data(:));
            maxi = max(obj.Data(:));
            obj.DisplayRange = [mini maxi];
        end
    end

end % end methods


%% Serialization methods
methods
    function str = toStruct(obj)
        str = struct('Type', 'kymorod.core.Kymograph', ...
            'Data', obj.Data, ...
            'DisplayRange', obj.DisplayRange, ...
            'Name', obj.Name, ...
            'TimeAxis', toStruct(obj.TimeAxis), ...
            'PositionAxis', toStruct(obj.PositionAxis));
    end
end

methods (Static)
    function kymo = fromStruct(str)
        % Create a new Kymograph instance from a Matlab struct.

        % check case of empty data -> return empty Kymograph
        if isempty(str)
            kymo = kymorod.core.Kymograph([]);
            return;
        end
        
        % create kymograph from data
        kymo = kymorod.core.Kymograph(str.Data, 'Name', str.Name);

        % aslo setup optional properties
        if ~isempty(str.DisplayRange)
            kymo.DisplayRange = str.DisplayRange;
        end
        if ~isempty(str.TimeAxis)
            kymo.TimeAxis = kymorod.core.PlotAxis.fromStruct(str.TimeAxis);
        end
        if ~isempty(str.PositionAxis)
            kymo.PositionAxis = kymorod.core.PlotAxis.fromStruct(str.PositionAxis);
        end
    end
end

end % end classdef

