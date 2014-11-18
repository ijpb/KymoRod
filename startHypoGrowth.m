function startHypoGrowth(varargin)
%STARTHYPOGROWTH  Run the 'hypogrowth' GUI
%
%   Usage:
%   startHypoGrowth
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-10-13,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

% create application data structure
app = HypoGrowthAppData;

% [path, name] = fileparts(mfilename('fullpath'));
path = fileparts(mfilename('fullpath'));
app.inputImagesDir = fullfile(path, '..', '..', 'sampleImages', '01');

% open first dialog of application
SelectInputImagesDialog(app);
