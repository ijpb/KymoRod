function Csc=setsc(C,sc)
%SETSC Open The functions C are rescaled with the scale sc pixel.mm^-1
%Csc=setsc(C,sc)
%
% C : Contour of the figure
% sc : the scale, define at the begin of parstart

% Return C who is rescaled with the scale sc pixel.mm^-1
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file
Csc=C./sc;
