function E=elong5(SQ1,SQ2,S1,S2,pic1,pic2,scale,shift1,shift2,ws,we)
%E=elong5(SQ1,SQ2,S1,S2,pic1,pic2,scale,shift1,shift2,ws,we)

disp=0;

%on fait correspondre sur l'image aux pixels par lequels passent le
%squelette, l'abscisse curviligne de la courbe et l'angle associ�
picSQ1=Func2Pic(pic1,SQ1,scale,shift1,S1);
picSQ2=Func2Pic(pic2,SQ2,scale,shift2,S2);

%L=20;
%L=0.5;
L=0.25;%2.*ws./scale;
a=0;
%on prend les points de l'image pour lesquels l'absciss curviligne passe,
%correspondat aux points ou passent le squelette.
[x1 y1]=find(picSQ1>0);
E=[0 1];
%on fait la PIV sur tous les points ou passent le squelette
we=min([we floor(length(x1)./5)]);
for k=1:1:length(x1)
    i=x1(k);
    j=y1(k);
    %on adapte notre fenetre de maniere a recupere la taille de fenetre ws
    %desiree apres rotation, et on v�rifie que tous les points sont bien
    %d�finis.
        if(i>ws && j>ws && (length(picSQ1(:,1))-i)>ws && (length(picSQ1(1,:))-j)>ws)
            
            %on initialise le fichier dans lequel on met les valeurs de la
            %correlation pour le point i j
            clear Corr;
            Corr=zeros(1,2);
            
            %on fait tourner l'image de mani�re � ce que les bords du
            %contour soient parrall�les au bord inf�rieur de l'image
            w1=double(pic1(i-ws:i+ws,j-ws:j+ws));
            V=std2(w1);
            if(V>1)
            
            %on r�cup�re ensuite l'image � la bonne taille de la fenetre
            %puis on calcule la moyenne et la variance (?) de celle ci
            %Ix=avgw(w1);
            %Normx=normal(w1,Ix);
            b=0;
            
            [x2 y2]=find(abs(picSQ2-picSQ1(i,j))<L & picSQ2>0); %faire attention � voire si il ne faut pas le changer

            for l=1:length(x2)
                u=x2(l);
                v=y2(l);
                    %on r�alise de m�me pour la fenetre d'investigation

                    
                    if(u>ws && v>ws && u<length(pic1(:,1))-ws && v<length(pic1(1,:))-ws)
                        b=b+1;


                        w2=double(pic2(u-ws:u+ws,v-ws:v+ws));               

                        %Iy=avgw(w2);
                        %Normy=normal(w2,Iy);
                        
                        %on peut donc calculer la corr�lation entre les
                        %deux images, on obtient une fonction qui nous done
                        %les valeurs de corr�lation en fonction de la
                        %diff�rence d'abscisse curviligne entre les deux
                        %points (le d�placement).
                        Corr(b,1)=picSQ2(u,v)-picSQ1(i,j);
                        Corr(b,2)=corr2(w1,w2);%sum(sum(( w1 - Ix ) .* (w2 - Iy )))/sqrt(Normx*Normy); 
                        %if disp==1;clear figure;subplot(2,2,1); imagesc(w1);subplot(2,2,2); imagesc(w2);drawnow; end;
                    
                    end
               
                
            end
            
            %On trouve le maximum de cor�lation ainsi que sa postion
            %en ordonnant Corr. Et on prend les un ou deux points adjacents pour
            %ajuster une gaussienne.

            Corr=sortrows(Corr,1);
            [Corrmax Corry]=max(Corr(:,2));
            fsz1=min([10 Corry-1]);
            fsz2=min([10 size(Corr,1)-Corry]);
            %if var(Corr(Corry-fsz1:Corry+fsz2,2))>1e-4
                a=a+1; 
                E(a,1)=picSQ1(i,j);
                E(a,2)=Corr(Corry,1);
            %end
            if disp==1;subplot(2,2,3);hold off;plot(Corr(:,1),Corr(:,2),'go',Corr(Corry,1),Corr(Corry,2),'r+'); drawnow;end;
            if disp==1;subplot(2,2,4);hold off;plot(E(:,1),E(:,2),'ro'); drawnow;end;


            clear x2;
            clear y2;
            end 
        end
end

E=sortrows(E,1);