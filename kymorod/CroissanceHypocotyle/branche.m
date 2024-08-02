function [SK, R, ordre] = branche(V, V_F, F, dist, jp, j, m, pere)
%BRANCHE Hierarchisation of the voronoi diagram
%[SK, R, ordre] = branche(V, V_F, F, dist, jp, j, m, pere)
%
% V sommet de voronoi
% C cellule de voronoi
% S_n contour
%in point � l'int�rieure du contour
%F_d=sommet externe c�te � c�te dans une cellule de voronoi avec un sommet externe
%v_F_d cardinal de F_d pour chaque sommet
%F_i, v_F_i idem sommet inetrieurs
%Fils_d_i=sommet interne c�te � c�te dans une cellule de voronoi avec un
%sommet externe
%F_d=sommet externe c�te � c�te dans une cellule de voronoi avec un
%sommet interne
%
%
% Return
% SK:   the skeleton
% R:    Radius of the skeleton
% ordre: gave a path at each branch of the skeleton whith 1 or 2. For
%       example a branch will become (1,2,2,1,1,1) 
%
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

persistent N SQ4 R2 ordre2;

hold on;
if pere==0 && m==0
    N = 1;
    SQ4=[];
    R2=[];
    ordre2=[];
end

i = 1;
SK1(i,1) = V(j,1);
SK1(i,2) = V(j,2);
R1(i) = dist(j);

if V_F(j) < 3
    jind = find(F{j} ~= jp);
    jp = j;
    j = F{j}(jind);
    V_F(j) = V_F(j)-1;
    
    while V_F(j) == 1
        i = i+1;
        SK1(i,1) = V(j,1);
        SK1(i,2) = V(j,2);
        R1(i) = dist(j);

        jind = find(F{j}~=jp);
        jp = j;
        j = F{j}(jind);
        V_F(j) = V_F(j)-1; 
    end
end

SQ4{N} = SK1;
R2{N} = R1;
    
% ordre2
if N == 1
    ordre2{N} = 1;
else
    ordre2{N} = [ordre2{pere} N];
end

pere = N;
if V_F(j) > 1
    jind = find(F{j}~=jp);
    j2 = F{j}(jind);
    N = N+1;
    branche(V, V_F, F, dist, j, j2(1), 1, pere);
    N = N+1;    
    branche(V, V_F, F, dist, j, j2(2), 2, pere);    
end

SK = SQ4;
R = R2;
ordre = ordre2;
