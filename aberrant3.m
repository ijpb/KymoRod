function Eab=aberrant3(E2)
%Eab=aberrant3(E2)
%kernel smoother

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


