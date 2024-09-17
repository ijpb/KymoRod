classdef ControlPanel < handle
% Parent class for control panels displayed at the left side of main frame.
%
%   Class ControlPanel
%
%   Example
%   ControlPanel
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-09-17,    using Matlab 24.2.0.2712019 (R2024b)
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    Frame;
    Handles;
    
    Padding = 5;

end % end properties


%% Constructor
methods
    function obj = ControlPanel(frame)
        % Constructor for ControlPanel class.

        obj.Frame = frame;
    end

end % end constructors


%% Methods
methods (Abstract)
    % Build the layout of the specified panel.
    populatePanel(obj, hPanel);

end % end methods

end % end classdef

