function kappa = computeVertexCurvature(obj, delta)
% Compute curvature of each vertex of a midline.
%
%   computeVertexCurvature(MIDLINE)
%   Computes the curvature of each vertex based on their coordinates, and
%   updates the "Curvatures" property.
%
%   Example
%     % create a smooth polygon
%     theta = linspace(0, 2*pi, 200);
%     rho = 45 + 15 * cos(3 * theta);
%     [x, y] = pol2cart(theta, rho);
%     midline = kymorod.data.Midline([x' y']);
%     fig1 = figure; hold on; axis equal; draw(midline, 'k');
%     % compute curvature of each vertex
%     kappa = computeVertexCurvature(midline, 5);
%     figure; plot(kappa); title('Curvature');
%     % draw osculating circle of a point with positive curvature
%     ind1 = 70;
%     pos = midline.Coords(ind1,:); figure(fig1); drawPoint(pos, 'bo');
%     tangent = (midline.Coords(ind1+1,:) - midline.Coords(ind1-1,:)) / 2;
%     normal = normalizeVector(rotateVector(tangent, pi/2));
%     posC = pos + inv(kappa(ind1)) * normal;
%     figure(fig1); drawCircle([posC abs(1/kappa(ind1))],'b')
%     % draw osculating circle of a point with negative curvature
%     ind2 = 35;
%     pos = midline.Coords(ind2,:); figure(fig1); drawPoint(pos, 'ro');
%     tangent = (midline.Coords(ind2+1,:) - midline.Coords(ind2-1,:)) / 2;
%     normal = normalizeVector(rotateVector(tangent, pi/2));
%     posC = pos + inv(kappa(ind2)) * normal;
%     figure(fig1); drawCircle([posC abs(1/kappa(ind2))],'r')
%
%   References
%   Laurent Younes, "Shapes and Diffeomorphisms", second edition, section
%   1.13 p 20.
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-12,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.


% create the matrix of second moments for dummy variable i
li = -delta:delta;
A00 = sum(li.^4/4);
A11 = sum(li.^2);
A22 = 2*delta+1;
A = [A00 0 A11/2 ; 0 A11 0 ; A11/2 0 A22];

% allocate memory
nv = size(obj.Coords, 1);
kappa = zeros(nv,1);

% iterate over inner vertices
for k = delta+1:nv-delta
    z0k = [0 0];
    z1k = [0 0];
    z2k = [0 0];
    for i = -delta:delta
        m = obj.Coords(k+i,:);
        z0k = z0k + m;
        z1k = z1k + i*m;
        z2k = z2k + i^2*0.5*m;
    end
    
    abc = A \ [z2k ; z1k ; z0k];
    kappa(k) = det(abc([2 1], 1:2)) / norm(abc(2,:))^3;
end

obj.Curvatures = kappa;
