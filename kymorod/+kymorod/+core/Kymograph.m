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

%% Static factories
methods (Static)
    function kymo = fromValues(S, V, nPoints, varargin)
        %FROMVALUES Compute kymograph from a cell array of values.
        %
        %   KYMO = kymographFromValues(SList, VList, NPoints)
        %   Computes a kymograph from the a of values associated with a
        %   list of curvilinear abscissa.
        %
        %   Input:
        %   * SList: the N-by-1 cell array containing the curvilinear
        %       abscissa for each signal 
        %   * VList: the N-by-1 cell array containing the signal values for each
        %       frame/image
        %   * NPoints: the number of points used for resampling each signal.
        %
        %   Output:
        %   KYMO: a NPoints-by-N array of doubles, containing NaN for undefined
        %       space-time positions.
        % number of signals, or frames
        nSignals = length(V);

        % keep min and max abscissa
        Smin = zeros(nSignals, 1);
        Smax = zeros(nSignals, 1);
        for k = 1:nSignals
            Smin(k,1) = S{k}(1);
            Smax(k,1) = S{k}(end);
        end

        % the largest abscissa
        L = max(Smax);

        % discretisation step of curvilinear abscissa
        DL = L / nPoints;

        % allocate memory for kymograph image data
        data = NaN * ones(nPoints, nSignals);

        % iterate on frames
        for k = 1:nSignals

            % sample NPoints points on the curvilinear abscissa
            for j = 1+round(Smin(k)/DL):round(Smax(k)/DL)
                % convert to curvilinear abscissa
                Sj = j * DL;

                % index of first point
                ind0 = find(S{k} < Sj, 1, 'last');
                if isempty(ind0)
                    ind0 = 1;
                end

                % index of last point
                ind1 = find(S{k} > Sj, 1, 'first');
                if isempty(ind1)
                    ind1 = length(S{k});
                end

                % curvilinear abscissa for first and last points
                S0 = S{k}(ind0);
                S1 = S{k}(ind1);

                % linear interpolation of the signal values around Sj
                data(j, k) = (V{k}(ind0)*(Sj-S0) + V{k}(ind1)*(S1-Sj)) / (S1-S0);
            end
        end
        
        kymo = kymorod.core.Kymograph(data);
        setNameValues(kymo, varargin{:});
    end
end


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

        setNameValues(obj, varargin{:});
    end

    function setNameValues(obj, varargin)
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
            error('Wrong number of input arguments when creating Kymograph');
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
        if isempty(obj.DisplayRange) || diff(obj.DisplayRange) == 0
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

