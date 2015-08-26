function startKymoRod(varargin)
%STARKYMOROD  Run the 'KymoRod' GUI
%
%   Usage:
%   startKymoRod
%
%   See also
%   setupKymoRod
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-10-13,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

%% Initialize logging process

% creates '.kymorod' directory if it does not exist
logdir = fullfile(getuserdir, '.kymorod');
if ~exist(logdir, 'dir')
    mkdir(logdir);
end

% create logger to user log file
logFile = fullfile(getuserdir, '.kymorod', 'kymorod.log');
logger = log4m.getLogger(logFile);

% setup log levels
setLogLevel(logger, log4m.DEBUG);
setCommandWindowLevel(logger, log4m.WARN);


%% Launch application

% open first dialog of application
KymoRodStartupDialog;
