function [C, A] = skeletonCurvature(SK, S, ws)
%SKELETONCURVATURE Compute orientation and curvature of a parameterized curve
%
% [A, C] = skeletonCurvature(SK, S, W)
% SK    a N-by-2 array containing the coordinate of vertices
% S     the value of the curvilinear abscissa
% W     the size of the window used to compute local angle
%
% A     the angle with the vertical, in a N-by-1 array
% C     the local curvature of the curve, in a N-by-1 array
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% vertex number
n = length(S);

% Computation of the angle A according to the vertical
A = skeletonVerticalAngle(SK, ws);

% fill extremities of angle signal with the last computed values
% ne pas oublier de corriger l'intervalle de calcul de courbure
% A(1:ws) = A(ws+1);            
% A(n-ws:end) = A(end-ws-1);    % avec ca

% (keep it or not ?)
% a virer pour retrouver les anciens resultats 
A = moving_average(A, ceil(ws/2));     % et ca

% The derivation of the angle A along the curvilinear abscissa S gives the 
% skeletonCurvature C 
C = zeros(n, 1);
for i = ws+1:n-ws
    C(i) = (A(i+ws) - A(i-ws)) / (S(i+ws) - S(i-ws));
end

% fill the extremities of the signal
C(1:ws) = (1:ws).*C(ws+1) / ws; %ca de meme pour avoir les points sur laquelle on a pas de courbure
C(n-ws:end) = (ws-(1:ws+1)) .* C(end-ws-1) / ws; %et ca pour etre tranquille

% keep it or not ?
C = moving_average(C, ceil(ws/2)); % et puis on degagera ca aussi


