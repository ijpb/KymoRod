function mov18d(green,SQ,scale,shift,S,S2,coord,direction,Elg,EE,clim,t0)
c=jet;
close all;
hf=figure; 
    drawnow;
mov=1;
[s1 s2]=size(green{1});
R=s2./s1;
set(hf,'Position',[0,0,600+ceil(R.*800)+mod(ceil(R.*800),2),800],'Color',[1 1 1]);
set(gcf,'PaperPositionMode','auto');
%set(gcf,'Visible','off');
%rect = get(hf,'Position')
if mov==1
movie=VideoWriter('joli2.avi');
movie.FrameRate=10;
open(movie);
end

[l1 l2]=size(EE);
for k=1:length(S)
    if isempty(S{k})==0
        Emin(k,1)=S2{k}(1,1);
        Emax(k,1)=S2{k}(end,1);
    else
        Emin(k,1)=1e19;
        Emax(k,1)=0;                
    end
end
ds=+min(Emin)+(0:l2-1)*(max(Emax)-min(Emin))/(l2-1);

T=(0:l1-1).*t0/60;
for i=1:length(SQ)-2

    disp(i);
    clf;
    subplot(1,3,1);
    S{i}=S{i}-S{i}(1);
    Elg{i}(:,1)=Elg{i}(:,1)-Elg{i}(1,1);
    aff4b(SQ{i},S{i},Elg{i},coord,direction,shift{i},scale,green{i},clim,c);
    set(gca,'XDir','reverse');
    set(gca,'Ytick',[],'Xtick',[]);
    %set(gca,'Position',[0,0,1,1]);
        subplot(1,3,2:3);
        EE2=EE.*nan;
        EE2(1:i,:)=EE(1:i,:);
caxis(clim);imagescnan(ds,T,EE2),colorbar;
xlabel('s(mm)','FontSize',15,'fontweight','b','FontName','Arial');
ylabel('t(h)','FontSize',15,'fontweight','b','FontName','Arial');
set(gca,'FontSize',15,'FontName','Arial');
    drawnow;
    if mov==1
        currFrame = getframe(hf,[0,0,600+ceil(R.*800)+mod(ceil(R.*800),2),800]);
        writeVideo(movie,currFrame);
        %F(i)=getframe(hf);
    end
end

if mov==1
    %movie2avi(F,'joli.avi','fps',7,'quality',100);
    close(movie);
end
disp('c est fini gros');