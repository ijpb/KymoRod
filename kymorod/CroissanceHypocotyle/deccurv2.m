function [S1 S2]=deccurv2(P,varargin)
%[S1 S2]=deccurv2(P,varargin)

if length(varargin)==1
    E=varargin{1};
else
    for k=1:length(varargin{1})
        E{k}(:,1)=varargin{1}{k};
        E{k}(:,2)=varargin{2}{k};
    end
end

for k=1:length(E);

    S1{k}(:,1)=P(k,1)-E{k}(:,1);     
    S1{k}(:,2)=E{k}(:,2);
    S1{k}=flipud(S1{k});
    if length(S1{k}(:,1))>1
        Smin(k,1)=S1{k}(1);
    else
        Smin(k,1)=1e-19;
    end
end

Sm=min(Smin);

for k=1:length(E);
    S2{k}(:,1)=S1{k}(:,1)-Sm;
    S2{k}(:,2)=S1{k}(:,2); 
end