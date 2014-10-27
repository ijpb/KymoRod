function A = CTangle2(CT, ws)
% CTANGLE2 Compute angle according to the vertical
%
% A = CTangle2(CT, ws)
% CT: skeleton of the figure
% ws: is the size of the derivative window
%
% Return A : value of the angle A
% 
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% number of vertices
n = length(CT);

% allocate memory
A = zeros(n,1);
T = zeros(n,1);

% starting index to fill the array
i = ws + 1;

% angle of first computed point
T(i) = (CT(i+ws,1)-CT(i-ws,1)) / (CT(i+ws,2)-CT(i-ws,2));
A(i) = atan(T(i));

% compute angle of remaining points
for i = ws+2:n-ws
	% current angle
    T(i) = (CT(i+ws,1)-CT(i-ws,1))/(CT(i+ws,2)-CT(i-ws,2));
    A(i) = atan(T(i));   
    
	% in case of dy < 0, fix something (?)
    if CT(i+ws,2) - CT(i-ws,2) < 0
        A(i) = A(i);
        if A(i) > 0
            A(i) = A(i)-pi;
        else
            A(i) = A(i)+pi;
        end
    end
end

% add smoothing
if length(A(ws+1:n-ws)) > 2*ws
    A(ws+1:n-ws) = moving_average(A(ws+1:n-ws), ws);
end

