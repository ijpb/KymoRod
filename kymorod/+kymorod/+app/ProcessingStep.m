classdef ProcessingStep < uint32
%  Enumeration of the different steps of the workflow.
%
%   The enumeration inherits an integer data type, making it possible to
%   compare processing steps together.
%
%   Example
%     step1 = kymorod.data.ProcessingStep.Segmentation;
%     step2 = kymorod.data.ProcessingStep.Midline;
%     b = step1 < step 2
%     ans = 
%         true
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-27,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.

%% Enumerates the different cases
enumeration
    % No image selected
    None(0)
    % images are selected
    Selection(10)
    % threshold is computed for all images
    Segmentation(20)
    % contour was computed
    Contour(30)
    % skeleton was computed and rescaled
    Skeleton(40)
    Midline(45)
    Curvature(50)
    Displacement(60)
    FilteredDisplacement(65)

    % elongation was computed and result images created
    Elongation(70)
    % kymograph displayed
    Kymograph(80)
    % Intensity kymograph computed
    Intensity(90)
end


%% Constructor
methods
    function obj = ProcessingStep(value, varargin)
        % Constructor for ProcessingStep class.

        % need to call explicitely the uint32 constructor.
        obj = obj@uint32(value);
    end

end % end constructors


%% Methods
methods
    function resetData(obj, analysis)
        % Reset some fields of the analysis.

        if obj == kymorod.app.ProcessingStep.None
            clearInputImages(analysis);
        elseif obj == kymorod.app.ProcessingStep.Selection
            clearSegmentations(analysis);
        elseif obj == kymorod.app.ProcessingStep.Segmentation
            clearContours(analysis);
        elseif obj == kymorod.app.ProcessingStep.Contour
            clearMidlines(analysis);
        elseif obj == kymorod.app.ProcessingStep.Skeleton
        elseif obj == kymorod.app.ProcessingStep.Midline
            clearCurvatures(analysis);
            clearDisplacements(analysis);
            clearIntensityData(analysis);
        elseif obj == kymorod.app.ProcessingStep.Curvature
        elseif obj == kymorod.app.ProcessingStep.Displacement
            clearFilteredDisplacements(analysis);
        elseif obj == kymorod.app.ProcessingStep.FilteredDisplacement
            clearElongationData(analysis);
        elseif obj == kymorod.app.ProcessingStep.Elongation
        elseif obj == kymorod.app.ProcessingStep.Intensity
        else
            warning('Unknown processing step: %s', obj);
        end

        function clearInputImages(analysis)
            clearSegmentations(analysis);
        end

        function clearSegmentations(analysis)
            clearContours(analysis);
        end

        function clearContours(analysis)
            analysis.Contours = {};
            clearMidlines(analysis);
        end

        function clearMidlines(analysis)
            analysis.Midlines = {};
            clearCurvatures(analysis);
        end

        function clearCurvatures(analysis)
            analysis.AlignedAbscissas = {};
            analysis.VerticalAngles = {};
            analysis.RadiusKymograph = [];
            analysis.VerticalAngleKymograph = [];
            analysis.CurvatureKymograph = [];
            % ideally, should also clear curvature data within midlines
            clearDisplacements(analysis);
        end

        function clearDisplacements(analysis)
            analysis.Displacements = {};
            clearFilteredDisplacements(analysis);
        end

        function clearFilteredDisplacements(analysis)
            analysis.FilteredDisplacements = {};
            clearElongationData(analysis);
        end

        function clearElongationData(analysis)
            analysis.Elongations = {};
            analysis.ElongationKymograph = [];
            clearIntensityData(analysis);
        end

        function clearIntensityData(analysis)
            analysis.IntensityKymograph = [];
        end

    end
end % end methods

end % end classdef

