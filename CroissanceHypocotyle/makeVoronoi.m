function [V C in] = makeVoronoi(S_n)

%Vornoisation
[V,C]=voronoin(S_n);
%Detection of the points inside the contour
in = inpolygon(V(:,1),V(:,2),S_n(:,1),S_n(:,2));