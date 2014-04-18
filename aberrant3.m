function Eab=aberrant3(E2)

%ABBERANT Smooth the curve and remove errors using kernel smoothers
%Eab=aberrant3(E2)
%
% E2 : a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa. gave by dispall()
%
% Return Eab :  a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa. But smooth by kernel smoother and whitout errors
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file
E=E2;
LX=.1;
LY=1e-2;
Smin=E2(1,1);
E(:,1)=E2(:,1)-Smin;
[X Y]= avgd(E,LX,LY,5e-3);

Eab(:,1)=X+Smin;
Eab(:,2)=Y;

%if length(Eab(:,2))>60
%    Eab(:,2)=moving_average(Eab(:,2),30);
%end


