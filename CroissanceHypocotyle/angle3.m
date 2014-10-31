function A=angle3(pc,pp,pf)
%ANGLE3 compute angle between three points
%
% A = angle3(pc,pp,pf)
%
%  donne l'angle entre 3 points pc point central
%

x1 = pp(1) - pc(1);
x2 = pf(1) - pc(1);

y1 = pp(2) - pc(2);
y2 = pf(2) - pc(2);

n1 = sqrt(x1.^2 + y1.^2);
n2 = sqrt(x2.^2 + y2.^2);

ps = x1.*x2 + y1.*y2;
A = acos((ps./(n1.*n2)));


