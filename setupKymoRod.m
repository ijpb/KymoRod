function setupKymoRod(varargin)
%SETUPKYMOROD Setup all paths required to run the KymoRod software
%
%   usage:
%   setupKymoRod
%
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-08-21,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

% extract parent path of the program
fileName = mfilename('fullpath');
mainDir = fileparts(fileName);

disp('Installing KymoRod software...');

% add libraries
addpath(fullfile(mainDir, 'lib'));
addpath(fullfile(mainDir, 'lib', 'matimage'));
addpath(fullfile(mainDir, 'lib', 'freezeColors'));
%addpath(fullfile(mainDir, 'lib', 'parfor'));

% add the core programs
addpath(fullfile(mainDir, 'core'));
addpath(fullfile(mainDir, 'CroissanceHypocotyle'));

% add GUI software
addpath(fullfile(mainDir, 'userInterface'));

% and the launcher
addpath(mainDir);

disp('KymoRod Software installed!');

