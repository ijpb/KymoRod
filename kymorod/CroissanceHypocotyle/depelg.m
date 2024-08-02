function Elg=depelg(dep,t0,step)
%Elg=depelg(dep,t0,step)
%Compute the elongation Elg by spatial derivation of the displacement
%between t0*step times

dep(:,1)=moving_average(dep(:,1),5);
dep(:,2)=moving_average(dep(:,2),5);
Elg=zeros(size(dep));
for i=2:size(dep,1)-1
    Elg(i,2)=(dep(i+1,2)-dep(i-1,2))/(dep(i+1,1)-dep(i-1,1))/(t0*step*60);
end

Elg(:,1)=dep(:,1);