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

methods (Static)
    function step = parse(value)
        % Identifies processing step from char array.
        %
        % Example:
        % step = ProcessingStep.parse('Skeleton');
        
        if ~ischar(value)
            error('requires a character array as input argument');
        end
        
        switch lower(value)
            case 'none',        step = ProcessingStep.None;
            case 'selection',   step = ProcessingStep.Selection;
            case 'threshold',   step = ProcessingStep.Threshold;
            case 'contour',     step = ProcessingStep.Contour;
            case 'skeleton',    step = ProcessingStep.Skeleton;
            case 'elongation',  step = ProcessingStep.Elongation;
            case 'kymograph',   step = ProcessingStep.Kymograph;
            otherwise
                error('Unrecognised Processing step name: %s', value);
        end
    end
end

end % end classdef

