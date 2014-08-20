function col=openall(color)
%OPENALL Open all files of the directory 'r' for red, 'g' for green or 'b' for blue
%Images must be in one color in one bit.
%
% Returns col, an array of cell with all the pictures
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

N=dir(strcat(color,'*'));
col=cell(9,1);
parfor i=1:9
    col{i}=imread(N(i+174).name);
end
 