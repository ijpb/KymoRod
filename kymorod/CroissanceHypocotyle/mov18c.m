function mov18c(green,SQ,CT,scale,shift)
c=jet;
close all;
hf=figure; 
drawnow;
mov=1;
[s1 s2]=size(green{1});
R=s2./s1;
set(hf,'Position',[0,0,ceil(R.*800)+mod(ceil(R.*800),2),800],'Color',[1 1 1]);
set(gcf,'PaperPositionMode','auto');
%set(gcf,'Visible','off');
%rect = get(hf,'Position')
if mov==1
movie=VideoWriter('SQ.avi');
movie.FrameRate=10;
open(movie);
end
for i=1:length(SQ)-2

    disp(i);
    clf;
    subimage(green{i});
    SQ{i}(:,1)=(SQ{i}(:,1)+shift{i}(1,1))*scale;
    SQ{i}(:,2)=(-SQ{i}(:,2)+shift{i}(1,2))*scale;
    CT{i}(:,1)=(CT{i}(:,1)+shift{i}(1,1))*scale;
    CT{i}(:,2)=(-CT{i}(:,2)+shift{i}(1,2))*scale;
    %S{i}=S{i}-S{i}(1);
    %Elg{i}(:,1)=Elg{i}(:,1)-Elg{i}(1,1);
    %aff4b(SQ{i},S{i},Elg{i},coord,direction,shift{i},scale,green{i},clim,c);
    aff(SQ{i},CT{i});
    plot(SQ{i}(1,1),SQ{i}(1,2),'yo');
    set(gca,'XDir','reverse');
    set(gca,'Ytick',[],'Xtick',[]);
    set(gca,'Position',[0,0,1,1]);
    drawnow;
    if mov==1
        currFrame = getframe(hf,[0,0,ceil(R.*800)+mod(ceil(R.*800),2),800]);
        writeVideo(movie,currFrame);
        F(i)=getframe(hf);
    end
end

if mov==1
    %movie2avi(F,'joli.avi','fps',7,'quality',100);
    close(movie);
end
disp('c est fini gros');