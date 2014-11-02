function MATfunc = Func2Pic(pic, func, scale, shift, S)
%FUNC2PIC Create an image of the curvilinear abscissa of a skeleton
%
% MATfunc = Func2Pic(pic, func, scale, shift, S)
%
% pic: 		directory of pictures (gave by openall())
% scale: 	the scale, define in parstart
% shift: 	Coordinates of the origin of the skeleton, bottom left
% Func: 	the skeleton
% S: 		curvilinear abscissa
%
%
% Return MATfunc, an image who say for each points who is the curvilinear abscissa
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% replace the curve "func" into the image space
func(:,1) = (func(:,1) + shift(1,1)) * scale;
func(:,2) = (-func(:,2) + shift(1,2)) * scale;

% allocate memory
MATfunc = zeros(size(pic));
avg = ones(size(pic));

for i = 1:size(func, 1)
	% compute indices in image space
	indi = round(func(i,2));
	indj = round(func(i,1));
	
	% update number of times current pixel was updated
    if MATfunc(indi, indj) > 0
        avg(indi, indj) = avg(indi, indj) + 1;
    end
	
	% add current abscissa
    MATfunc(indi, indj) = MATfunc(indi, indj) + S(i);
end

% normalisation
MATfunc = MATfunc ./ avg;

