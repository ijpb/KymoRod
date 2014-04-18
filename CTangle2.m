function A=CTangle2(CT,ws)
%CTANGLE2 Computation of the angle A according to the vertical
% A=CTangle2(CT,ws)
%
% CT : skeleton of the figure
% ws : is the size of the derivative window, define at the begin
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
n=length(CT);

A=zeros(n,1);
T=zeros(n,1);
m=zeros(n,1);
i=ws+1;
T(i)=(CT(i+ws,1)-CT(i-ws,1))/(CT(i+ws,2)-CT(i-ws,2));
A(i)=atan(T(i));


%on calcule l'angle A de la courbe avec la verticale
for i=ws+2:n-ws
    T(i)=(CT(i+ws,1)-CT(i-ws,1))/(CT(i+ws,2)-CT(i-ws,2));
    A(i)=atan(T(i));   
    
    if CT(i+ws,2)-CT(i-ws,2)<0
        A(i)=A(i);
        if A(i)>0
            A(i)=A(i)-pi;
        else
            A(i)=A(i)+pi;
        end
    end
    

end



if(length(A(ws+1:n-ws))>2*ws)
    A(ws+1:n-ws)=moving_average(A(ws+1:n-ws),ws);
end

