function aff4b(SQ,S,C,coord,dir,shift,scale,green,clim,c)

if size(C,2)==1
    DG(:,1)=S;
    DG(:,2)=C;
    pos=1:length(DG);
else
    DG=C;
    if length(DG)>2
        for j=1:length(DG)
            
            pos(1)=1;
            pos(j+1)=find(S<=DG(j,1),1,'last');
    
        end
    end
end
    
    
st=0.66;
if coord==0
    SQ(:,1)=(SQ(:,1)+shift(1,1))*scale;
    SQ(:,2)=(-SQ(:,2)+shift(1,2))*scale;
elseif strcmp(dir,'droit')==1 || strcmp(dir,'droit2')==1
    SQ(:,1)=(SQ(:,1)+shift(1,1))*scale;
    SQ(:,2)=(-SQ(:,2)+shift(1,2))*scale;%+coord;
elseif strcmp(dir,'penche')==1 || strcmp(dir,'penche2')==1
    SQ(:,1)=(SQ(:,1)+shift(1,1))*scale+coord;
    SQ(:,2)=(-SQ(:,2)+shift(1,2))*scale;   
end
subimage(green);



if length(DG)>2
u(1)=DG(1,1);
for j=1:length(DG)
    
    u(j+1)=DG(j,2);
end
pos(j+2)=length(S);
l=length(c);
step=1;

for j=1:step:length(pos)-step-1
    
    v=round(l*(u(j)-clim(1))/(clim(2)-clim(1)));
    if v<1
        v=1;
    elseif v>l
        v=l;
    end
    hold on;
    plot(SQ(pos(j):pos(j+step),1),SQ(pos(j):pos(j+step),2),'LineWidth',7,'color',c(v,:));

end
end