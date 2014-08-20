function [tdecr tdech Elgr Elgh]=hyprootdec(Elg,SK,shift,scale,red)

tdecr=length(Elg);
tdech=length(Elg);
for k=1:length(Elg)
    SK{k}(:,2)=(-SK{k}(:,2)+shift{k}(1,2))*scale; 
    Str=find(Elg{k}(:,1)>0,1,'first');
    if min(SK{k}(:,2))<50 && tdech==length(Elg)
        tdech=k;
    elseif tdech==length(Elg)
        Elgh{k}(:,1)=abs(Elg{k}(Str:end,1)-Elg{k}(Str,1));
        Elgh{k}(:,2)=Elg{k}(Str:end,2);

    end
    if max(SK{k}(:,2))>size(red{1},1)-50 && tdecr==length(Elg)
        tdecr=k;
    elseif tdecr==length(Elg)

        Elgr{k}(:,1)=abs(Elg{k}(1:Str,1)-Elg{k}(1,1));
        Elgr{k}(:,2)=Elg{k}(1:Str,2);  
        
    end
    end
end




        

