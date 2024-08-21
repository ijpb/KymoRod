function elong = computeElongations(displ, ws, dt)
%COMPUTEELONGATIONS Compute elongation by spatial derivation of the displacement
% 
%   ELG = computeElongations(DSP, WS, DT)
%
%   Input arguments:
%   DSP:    a N-by-2 numeric array containing the curvilinear abscissa and
%           the displacement values along the midline
%   WS: 	size of the window for computing spatial derivative
%   DT: 	time between two frames, in user units
%
%   Output arguments:
%   ELONG:  a N-by-2 array containing the curvilinear abscissa and the
%           elongation computed for each point
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-21,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

% pad displacement by repeating end values
n = size(displ,1);
displ = displ([ones(1,ws) 1:n n*ones(1,ws)], :);

% compute elongation as the derivative of displacement
elong = (displ(2*ws+1:end,2) - displ(1:end-2*ws,2)) ./ (displ(2*ws+1:end,1) - displ(1:end-2*ws,1)) / dt;

% remove padding and concatenate with curvilinear abscissa
elong = [displ(ws+1:end-ws,1) elong]; 
