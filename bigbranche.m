function [SQ2 R2]=bigbranche(SQ,ordre,R)
%[SQ2 R2]=bigbranche(SQ,ordre,R)


for k=1:length(SQ)
    if length(SQ{k})>10
        S{k}=curvilin(SQ{k});
        L(k)=S{k}(end);
    else
        S{k}=0;
        L(k)=sqrt((SQ{k}(1,1)-SQ{k}(end,1)).^2+(SQ{k}(1,2)-SQ{k}(end,2)).^2);
    end
end


for k=1:length(ordre)
    L2(k)=sum(L(ordre{k}));
end

I=find(L2==max(L2));
SQ2=SQ{1};
R2=R{1}';

if length(I)>1
    for Ik=I
        IL=length(ordre{Ik});
    end
    u=find(IL==max(IL));
    I=Ik(u);
end

for j=2:length(ordre{I})
    k=ordre{I}(j);
    SQ2=[SQ2;SQ{k}];
    R2=[R2;R{k}'];
end