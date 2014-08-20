function [R_ma R_ma_ind dist2] = DirectionInitial(dist2,dir2,V,V_F,in)
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