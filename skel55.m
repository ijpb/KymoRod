function [SK CT2 shift R error]=skel55(CT,dir,dir2)    
%SKELL55 Skeletonization SK of the contour CT by voronoisaition
%[SK CT2 shift rad error]=skel55(CT,dir,dir2)
%
% CT2 : Contour of the figure
% dir : direction of the filters define at the begin of parstart
% dir2 : start of the filter (left,right,top or bottom) define at the begin of parstart
%
%Return : SK : the skeleton of the figure Nom the point at bottom left of skeleton is at bottom left of the image
% CT2 : New contour with new coordinates. Nom the point at bottom left of contour is at bottom left of the image
% shift : Coordinates of the origin of the skeleton, bottom left
% R : Radius
% error : if there is error during skeletonization
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

%Low pass filter of the contour
S_n=CTfilter(CT,200,dir);


SK=zeros(2,2);
R=0;

%Vornoisation
[V,C]=voronoin(S_n);
%Detection of the points inside the contour
in = inpolygon(V(:,1),V(:,2),S_n(:,1),S_n(:,2));
    
%V sommet de voronoi
%C cellule de voronoi
%S_n contour
%in point � l'int�rieure du contour

%F_d=sommet externe c�te � c�te dans une cellule de voronoi avec un sommet externe
%v_F_d cardinal de F_d pour chaque sommet
%F_i, v_F_i idem sommet inetrieurs
%Fils_d_i=sommet interne c�te � c�te dans une cellule de voronoi avec un
%sommet externe
%F_d=sommet externe c�te � c�te dans une cellule de voronoi avec un
%sommet interne

s1=size(S_n,1);
v1=size(V,1);
c1=size(C,1);

V_F=zeros(v1,1);

Point_bord=zeros(v1,3);

dist=zeros(v1,1);
Ind=ones(v1,1);

% Pour un sommet de voronoi tous les points du bord qui font ce sommet
% (logiquement 3)
for i=1:s1
    l=length(C{i});
    for j=1:l
        Point_bord(C{i}(j),Ind(C{i}(j)))=i;
        Ind(C{i}(j))=Ind(C{i}(j))+1;
    end
end


for i=1:v1
    
    dist(i)=norm(S_n(Point_bord(i,1),:)-V(i,:));

end

%on cherche les voisins des points du contour interieur

for i=1:c1
    
    h=length(C{i});
    for k=1:h

        B_k=in(C{i}(k));
        if(B_k==1)
         j1=k-1;
         j2=k+1;
           if k==1
               j1=h;
           end
           if k==h
               j2=1;
           end
           
              
                 B_j=in(C{i}(j1));
                 %on ne s'occupe que des points interieur-interieur nombre
                 %de voisin et positions dans la chaine
                 if (B_j==1)
                    V_F(C{i}(k))=V_F(C{i}(k))+1;
                    F{C{i}(k)}(V_F(C{i}(k)))=C{i}(j1);
                  end

                 B_j=in(C{i}(j2));
                 
                 if (B_j==1)
                    V_F(C{i}(k))=V_F(C{i}(k))+1;
                    F{C{i}(k)}(V_F(C{i}(k)))=C{i}(j2);
                 end

        
            if (V_F(C{i}(k))>0)
                 %on �vite les redites
                 F{C{i}(k)}=unique(F{C{i}(k)}); 
                 V_F(C{i}(k))=length(F{C{i}(k)}');
            
            end
        end
    end
    
end
for i=1:v1
    
    if V_F(i)==0
        dist2(i)=1e4;
    else
        dist2(i)=norm(V(i,:)-V(F{i}(1),:));
    end
end
    %On choisit le point de d�part en prenant 
    %le point le plus �loign� du contour verifiant les contraintes 1 seul
    %voisin et ...
    dist2=dist2';
    %[R_ma,R_ma_ind]=max((1./dist).*(V_F==1).*(1./dist2));%.*(d_bordn>seuil));
    
    %remettre la ligne suivant pour les calculs sur l'hypocotyle d'Arabido
    %[R_ma,R_ma_ind]=max((1.*V(:,2)).*(V_F==1).*in);
    switch dir2
        case 'left'
            [R_ma,R_ma_ind]=max((1./V(:,1)).*(V_F==1).*in);
        case 'right'
            [R_ma,R_ma_ind]=max((1.*V(:,1)).*(V_F==1).*in);
        case 'bottom'
            [R_ma,R_ma_ind]=max((1.*V(:,2)).*(V_F==1).*in);
        case 'top'
            [R_ma,R_ma_ind]=max((1./V(:,2)).*(V_F==1).*in);
    end 

    j=R_ma_ind;
    jp=j;
    i=1;
    close all;
    
    %Hierarchisation of the voronoi diagram
    [SK2 R2 ordre]=branche(V,V_F,F,dist,jp,j,0,0);
    %the skeleton SK is the biggest branch of the diagram
    [SK R]=bigbranche(SK2,ordre,R2);
    
    
   % coordinates at bottom left
    shift=SK(1,:);
   % For new contour, align at bottom left 
    CT2(:,1)=CT(:,1)-SK(1,1);
    CT2(:,2)=-(CT(:,2)-SK(1,2));   
   % for new Skeleton, align at bottom left 
    SK(:,1)=SK(:,1)-SK(1,1);
    SK(:,2)=-(SK(:,2)-SK(1,2));
    
