function E = elong5(SQ1, SQ2, S1, S2, pic1, pic2, scale, shift1, shift2, ws, we)
%ELONG5 Compute the growth between two successive images
% 
% E = elong5(SQ1, SQ2, S1, S2, pic1, pic2, scale, shift1, shift2, ws, we)
%
% SQ1: 		skeleton number one
% SQ2: 		skeleton number two
% S1: 		curvilinear abscissa number one
% S2: 		curvilinear abscissa number two
% Pic1: 	image number one
% Pic2: 	image number two
% scale: 	the scale, define in parstart
% shift1: 	Coordinates of the origin of the skeleton number one, bottom left
% shift2: 	Coordinates of the origin of the skeleton number two, bottom left
% ws: 		size of the correlation window
% we: 		unnecessary in this program
%
% E: a N-by-2 array, containing for each vertex the curvilinear abscissa and the displacement
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% % flag for displaying evolution of computation or not
% disp = 0;

% on fait correspondre sur l'image aux pixels par lequels passent le
% squelette, l'abscisse curviligne de la courbe
picSQ1 = Func2Pic(pic1, SQ1, scale, shift1, S1);
picSQ2 = Func2Pic(pic2, SQ2, scale, shift2, S2);

dim = size(pic1);

%L=20;
%L=0.5;
L = 0.25; %2.*ws./scale;
a = 0;

% on prend les points de l'image pour lesquels l'absciss curviligne passe,
% correspondant aux points ou passent le squelette.
[x1, y1] = find(picSQ1 > 0);
E = [0 1];

% we = min([we floor(length(x1)./5)]);

% on applique la PIV sur tous les points ou passent le squelette
for k = 1:length(x1)
	% indices of current point
    i = x1(k);
    j = y1(k);
    
    % on adapte notre fenetre de maniere a recupere la taille de fenetre ws
    % desiree apres rotation, et on verifie que tous les points sont bien
    % definis.
    % 	if i>ws && j>ws && (length(picSQ1(:,1))-i)>ws && (length(picSQ1(1,:))-j)>ws
    
    % process only skeleton points that are not too close from border
    if i <= ws || j <= ws || (dim(1)-i) <= ws || (dim(2)-j) <= ws
        continue;
    end
    
    % on initialise le fichier dans lequel on met les valeurs de la
    % correlation pour le point i j
    clear Corr;
    Corr = zeros(1,2);
    
    % on fait tourner l'image de maniere a ce que les bords du
    % contour soient parralleles au bord inf�rieur de l'image
    w1 = double(pic1(i-ws:i+ws, j-ws:j+ws));
    
    % compute PIV only if variability in window is sufficient
    V = std2(w1);
    if V <= 1
        continue;
    end
        
    % on recupere ensuite l'image a la bonne taille de la fenetre
    % puis on calcule la moyenne et la variance (?) de celle ci
    % Ix=avgw(w1);
    % Normx=normal(w1,Ix);
    b = 0;
    
    % faire attention: voire si il ne faut pas le changer
    [x2, y2] = find(abs(picSQ2-picSQ1(i,j)) < L & picSQ2 > 0);
    
    % process only neighbor points that are not too close from border
    inds = (x2 > ws) & (x2 < dim(1)-ws) & (y2 > ws) & (y2 < dim(2)-ws);
    x2 = x2(inds);
    y2 = y2(inds);
    
    for l = 1:length(x2)
        % indices of positions in second image
        u = x2(l);
        v = y2(l);
        
        b = b + 1;
        
        w2 = double(pic2(u-ws:u+ws, v-ws:v+ws));
        
        % Iy=avgw(w2);
        % Normy=normal(w2,Iy);
        
        % on peut donc calculer la correlation entre les deux images, on
        % obtient une fonction qui nous donne les valeurs de correlation en
        % fonction de la  difference d'abscisse curviligne entre les deux
        % points (le deplacement).
        Corr(b, 1) = picSQ2(u,v) - picSQ1(i,j);
        Corr(b, 2) = corr2(w1, w2);
        %sum(sum(( w1 - Ix ) .* (w2 - Iy )))/sqrt(Normx*Normy);
        %if disp==1;clear figure;subplot(2,2,1); imagesc(w1);subplot(2,2,2); imagesc(w2);drawnow; end;
        % 				end
    end
			
    % On trouve le maximum de correlation ainsi que sa postion
    % en ordonnant Corr. Et on prend les un ou deux points adjacents pour
    % ajuster une gaussienne.
    
    Corr = sortrows(Corr,1);
    [Corrmax, Corry] = max(Corr(:,2)); %#ok<ASGLU>
    %fsz1=min([10 Corry-1]);
    %fsz2=min([10 size(Corr,1)-Corry]);
    %if var(Corr(Corry-fsz1:Corry+fsz2,2))>1e-4
        a = a + 1;
        E(a,1) = picSQ1(i, j);
        E(a,2) = Corr(Corry,1);
    %end

% 			if disp == 1
% 				subplot(2,2,3);
% 				hold off;
% 				plot(Corr(:,1), Corr(:,2), 'go', Corr(Corry,1), Corr(Corry,2), 'r+'); 
% 				drawnow;
% 			end
% 			
% 			if disp == 1
% 				subplot(2,2,4); hold off;
% 				plot(E(:,1), E(:,2), 'ro'); 
% 				drawnow;
% 			end

% 			clear x2;
% 			clear y2;
            
% 		end 
% 	end
end

E = sortrows(E, 1);
