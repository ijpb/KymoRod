function CT2 = smoothContour(CT, F)
%SMOOTHCONTOUR Smooth a polygonal contour by applying moving average
%
%   CT2 = smoothContour(CT, F) 
%   Quickly smooths the polygonal contour CT by averaging each element with
%   the F elements at his right and the F elements at his left. The
%   elements at the ends are also averaged but the extremes are 
%   left intact.
%
%   Based on the "moving_average" function, 
%   by Carlos Adri�n Vargas Aguilera. nubeobscura@hotmail.com

if F > size(CT, 1)
    error('Requires contour length greater than smoothing window');
end

% creates circular contour
CT = CT([end-F+1:end 1:end 1:F], :);

% Moving average method, except the ends:
CTx = boxcar_window(CT(:,1), F);
CTy = boxcar_window(CT(:,2), F);
CT2 = [CTx(F+1:end-F) CTy(F+1:end-F)];

function Y = boxcar_window(X, F)
% Boxcar window of length 2F+1 via recursive moving average (really fast)
%
% nubeobscura@hotmail.com

if F == 0
    Y = X;
    return
end

% filter width
Wwidth = 2 * F + 1;
Y = zeros(size(X));          
Y(F+1) = sum(X(1:Wwidth));

% recursive moving average
N = length(X);
for n = F+2:N-F
    Y(n) = Y(n-1) + X(n+F) - X(n-F-1);
end
Y = Y / Wwidth;

