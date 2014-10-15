function [S1, S2] = deccurv(E, P)
% ???
%
% [S1, S2] = deccurv(E, P)
% E: list of original data vectors
% P: list of curvilinear abscissa that mark the transitions
% S1 

% 
S1 = E;
S2 = E;
Smin = zeros(length(E), 1);

for k=1:length(E);

    S1{k}(:,1) = E{k}(:,1) - P(k,1);     

    Smin(k,1) = S1{k}(1);
end

Sm = min(Smin);

for k = 1:length(E);
    S2{k}(:,1) = S1{k}(:,1) - Sm; 
end