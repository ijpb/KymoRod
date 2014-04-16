function [S1 S2]=deccurv(E,P)
%[S1 S2]=deccurv(E,P)

S1=E;
S2=E;
for k=1:length(E);

    S1{k}(:,1)=E{k}(:,1)-P(k,1);     

    Smin(k,1)=S1{k}(1);
end

Sm=min(Smin);

for k=1:length(E);
    S2{k}(:,1)=S1{k}(:,1)-Sm; 
end