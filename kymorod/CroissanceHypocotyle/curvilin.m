function S = curvilin(SK)
%CURVILIN Compute the curvilinear abscissa of a curve
%
% S = curvilin(SK)
% SK: 	a N-by-2 array containing coordinates of curve vertices
% S: 	a N-by-1 array containing the curvilinear abscissa of each vertex 
% 
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

S = zeros(length(SK), 1);

for i = 2:length(SK)-1
    S(i) = ((((SK(i+1,1)-SK(i-1,1)).^2)+((SK(i+1,2)-SK(i-1,2)).^2)).^(1/2))./(2)+S(i-1);
	% moyenne de dx/di, vectorisation potentielle, regarder fct 'hypot' 
end

S(end) = 2*S(end-1) - S(end-2);
