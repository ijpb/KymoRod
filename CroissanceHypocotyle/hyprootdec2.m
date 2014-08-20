function [Ar Ah tdecr tdech]=hyprootdec2(SK,shift,scale,red,varargin)
%[Ar Ah tdecr tdech]=hyprootdec2(SK,shift,scale,red,varargin)


if length(varargin)==2
    for k=1:length(varargin{1})
        A{k}(:,1)=varargin{1}{k};
        A{k}(:,2)=varargin{2}{k};
    end
else
    A=varargin{1};
end
    
tdecr=length(A);
tdech=length(A);
for k=1:length(A)
    SK{k}(:,2)=(-SK{k}(:,2)+shift{k}(1,2))*scale; 
    Str=find(A{k}(:,1)>0,1,'first');
    if min(SK{k}(:,2))<50 && tdech==length(A)
        tdech=k;
    elseif tdech==length(A)
        Ah{k}(:,1)=abs(A{k}(Str:end,1)-A{k}(Str,1));
        Ah{k}(:,2)=A{k}(Str:end,2);

    end
    if max(SK{k}(:,2))>size(red{1},1)-50 && tdecr==length(A)
        tdecr=k;
    elseif tdecr==length(A)

        Ar{k}(:,1)=abs(A{k}(1:Str,1)-A{k}(1,1));
        Ar{k}(:,2)=A{k}(1:Str,2);  
        
    end
end
end




        

