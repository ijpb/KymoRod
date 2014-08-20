function [Ltot Lzc Emoy vc I]=growthlength(Elg)
%[Ltot Lzc Emoy vc I]=growthlength(Elg)

for k=1:length(Elg)

    if isempty(Elg{k})==1
        Elg{k}=[0 0];
    end
    I{k}(:,1)=Elg{k}(:,1);
    for j=1:size(Elg{k},1)
        
        I{k}(j,2)=integrate(Elg{k},1,j);
    end
    I{k}(:,2)=I{k}(:,2)./max(I{k}(:,2));

    Ltot(k,1)=Elg{k}(end,1);

    indLzc=find(I{k}(:,2)>0.8,1,'first');
    ind0=find(I{k}(:,1)>0,1,'first');
    if isempty(indLzc)==0
        Lzc(k,1)=I{k}(indLzc,1);
        M=Elg{k}(ind0:indLzc,2);
        Emoy(k,1)=mean(M(isfinite(M)));
        vc(k,1)=integrate(Elg{k},ind0,indLzc);
    elseif k>1
        Lzc(k,1)=Lzc(k-1,1);   
        Emoy(k,1)=Emoy(k-1,1);
        vc(k,1)=vc(k-1,1);
    else
        Lzc(k,1)=0;   
        Emoy(k,1)=0;
        vc(k,1)=0;
    end
    
    
end