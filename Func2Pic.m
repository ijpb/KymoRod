function MATfunc=Func2Pic(pic,func,scale,shift,S)
%MATfunc=Func2Pic(pic,func,scale,shift,S)

func(:,1)=(func(:,1)+shift(1,1))*scale;
func(:,2)=(-func(:,2)+shift(1,2))*scale;


MATfunc=zeros(size(pic));

avg=ones(size(pic));

for i=1:length(func(:,1))
    if MATfunc(round(func(i,2)),round(func(i,1)))>0
        avg(round(func(i,2)),round(func(i,1)))=1+avg(round(func(i,2)),round(func(i,1)));
    end
    MATfunc(round(func(i,2)),round(func(i,1)))=S(i)+MATfunc(round(func(i,2)),round(func(i,1)));
    
end

MATfunc=MATfunc./avg;
    
    
        
        

