function [A, C] = curvature(SK, S, ws)
%CURVATURE Compute orientation and curvature of a parameterized curve
%
% SK : skeleton of the figure
% S : the value of the curvilinear abscissa
% ws is the size of the derivative window, define at the begin
%
% Return : the angle A with the vertical, an array of cell
% the curvature C of the Skeleton SK, an array of cell
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

% initialize empty arrays
A = zeros(n, 1);
C = zeros(n, 1);

% Computation of the angle A according to the vertical
A = CTangle2(SK, ws);

% fill extremities of angle signal with the last computed values
% (keep it or not ?)
A(1:ws) = A(ws+1);            %� virer pour retrouver les anciens r�sultats ne pas oublier de corriger l'intervalle de calcul de courbure
A(n-ws:end) = A(end-ws-1);    %avec ca
A = moving_average(A, ceil(ws/2));     %et ca

% The derivation of the angle A along the curvilinear abscissa S gives the 
% curvature C 
for i = ws+1:n-ws
    C(i) = (A(i+ws) - A(i-ws)) / (S(i+ws) - S(i-ws));
end

% fill the extremities odf the signal
C(1:ws) = (1:ws).*C(ws+1)/ws; %ca de meme pour avoir les points sur laquelle on a pas de courbure
C(n-ws:end) = (ws-(1:ws+1)).*C(end-ws-1)/ws; %et ca pour etre tranquille

% keep it or not ?
C = moving_average(C,ceil(ws/2)); % et puis on d�gagera ca aussi


