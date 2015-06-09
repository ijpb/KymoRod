classdef ProcessingStep < uint32
%PROCESSINGSTEP Enumeration class for the different steps of the workflow
%
%   Class ProcessingStep
%
%   Example
%   ProcessingStep
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-06-09,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - BIA-BIBS.

%% Enumerates the different cases
enumeration
    % No image selected
    None(0)
    % images are selected
    Selection(10)
    % threshold is computed for all images
    Threshold(20)
    % contour was computed
    Contour(30)
    % skeleton was computed and rescaled
    Skeleton(40)
%     Curvature(50)
%     Displacement(60)
    
    % elongation was computed and result images created
    Elongation(70)
    % kymograph displayed
    Kymograph(80)
end

end % end classdef

